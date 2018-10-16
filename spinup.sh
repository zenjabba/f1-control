#!/bin/bash
# User Configuration Section
# This is the user configuration section
# $1 = Name of Instance
# $2 = Zone to run it in

BOLD=$(tput bold)
NORMAL=$(tput sgr0)

MACHINE_TYPE="n1-standard-8"

if [ "$#" -ne 0 ]
then
	sleep 1
	
else
	echo "This script needs to take 2 variables ie, $0 instance_name zone"
fi

INSTANCE_NAME=$1
ZONE=$2

get_default_project () {

PROJECTID=$(sudo -s gcloud projects list --uri)
PROJECTID=$(basename $PROJECTID)

}

spin_up_instance () {


sudo -s gcloud beta compute instances create $INSTANCE_NAME --quiet --zone=$ZONE \
--machine-type=$MACHINE_TYPE --subnet=default --network-tier=PREMIUM --no-restart-on-failure \
--maintenance-policy=TERMINATE --preemptible  \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
--image=ubuntu-1604-xenial-v20181004 \
--image-project=ubuntu-os-cloud \
--boot-disk-size=10GB \
--boot-disk-type=pd-standard \
--boot-disk-device-name=$INSTANCE_NAME 
}

configure_rclone () {

echo "Configure rclone for your new instance $BOLD$INSTANCE_NAME $NORMAL"

sudo -s gcloud compute config-ssh --quiet > /dev/null
sudo -s gcloud compute ssh --zone $ZONE $INSTANCE_NAME -- 'mkdir -p /root/.config/rclone'

sudo -s gcloud compute ssh  --quiet --zone $ZONE $INSTANCE_NAME -- 'curl https://raw.githubusercontent.com/zenjabba/f1-control/master/install-gce-copier.sh | sudo bash'
echo "Please define source:/ for source location and destination:/ for destination location"
sudo -s gcloud compute ssh --zone $ZONE $INSTANCE_NAME -- '/usr/bin/rclone config --config=/root/.config/rclone/rclone.conf'
sudo -s gcloud compute ssh --quiet --zone $ZONE $INSTANCE_NAME -- 'reboot'

}

configure_gcloud () {

sudo -s gcloud config set project $PROJECTID

}

generate_crontab () {

crontab -l | { cat; echo "0 * * * * /opt/f1-control/gcerevive.sh $INSTANCE_NAME $ZONE $PROJECTID"; } | crontab -

}

google_available () {

echo "Sleeping till instance comes up"

IP=$(gcloud compute instances list | awk '/'$INSTANCE_NAME'/ {print $5}')

if nc -w 1 -z $IP 22; then
    echo "Success! Instance available"
    sleep 10
else
    sleep 10
    google_available
fi

}

# business end of the script

get_default_project
configure_gcloud
spin_up_instance

if [ $? == 0 ]
then
    echo ""
		
else
	echo "$BOLDSpinup failed.$NORMAL Fix the error and start again with $0 $1 $2"
	exit $?
fi


configure_rclone
generate_crontab

echo "Access this instance with the command $BOLD# sudo -s gcloud beta compute ssh $INSTANCE_NAME --zone $ZONE --project=$PROJECTID$NORMAL"
