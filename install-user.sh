#!/bin/bash
# User Configuration Section
# This is the user configuration section
# $1 = Name of Instance
# $2 = Zone to run it in. If nothing is supplied, defaults are made


if [ "$#" -ne 0 ]
then
	echo "This script can take 2 variables ie, $0 instance_name gce_zone"
	echo "Defaulting to instance name of rclone-copier and GCE Zone of us-east1-a"
else
	sleep 1
fi

if [ -z "$1" ]
then
	INSTANCE_NAME="rclone-copier"
else
	INSTANCE_NAME=$1
fi

if [ -z "$2" ]
then
	ZONE="us-east1-a"
else
    ZONE="$2"
fi

RCLONE_CONFIG_FILE=/tmp/gce-rclone.conf

declare -a myarray

check_rclone_installed () {

command -v rclone 2>/dev/null -v rclone >/dev/null 2>&1 || { echo >&2 "Please Install rclone... Aborting."; exit 1; }

}

configure_rclone () {

check_rclone_installed

echo "This will create a TEMP rclone.conf in $RCLONE_CONFIG_FILE"
echo ""
echo "Please configure source drive location"
echo ""
echo "Please use client_id = 930690570454-ra711ct2peggpt0g98h09l56m0qt99td.apps.googleusercontent.com"
echo "Please use client_secret = kjlPXSlrlY9PPjzKlNIP2dNE"

rclone config --config=$RCLONE_CONFIG_FILE

echo "Please configure destination drive location"
echo ""
echo "Please use client_id = 930690570454-ra711ct2peggpt0g98h09l56m0qt99td.apps.googleusercontent.com"
echo "Please use client_secret = kjlPXSlrlY9PPjzKlNIP2dNE"

rclone config --config=$RCLONE_CONFIG_FILE

#rclone config create source_team_drive drive --config=/tmp/$RCLONE_CONFIG_FILE --drive-client-id=930690570454-ra711ct2peggpt0g98h09l56m0qt99td.apps.googleusercontent.com --drive-client-secret=kjlPXSlrlY9PPjzKlNIP2dNE 

}

parse_rclone_config () {



# Load file into array.
let i=0
while IFS=$'\n' read -r line_data; do
    myarray[i]="${line_data}"
    ((++i))
done < $RCLONE_CONFIG_FILE

# Explicitly report array content.
let i=0
while (( ${#myarray[@]} > i )); do
    printf "${myarray[i++]}\n"
done

}

get_endpoint_information () {

echo "What was the source rclone remote name eg: source_team_drive:/"
read source_endpoint
echo "What was the destination rclone remote name eg: destination_team_drive:/"
read dest_endpoint
echo $source_endpoint $dest_endpoint >> /tmp/gce-collectionofremotes
echo "What is the project name eg: [RCLONE-SOURCE-DESTINATION]"
read project_name
echo "What is the WEBHOOK you want me to send this updates too (Optional)"
read webhook
echo "What is the CHANNEL you want me to send the updates too (Optional)"
read channel
echo "#" >> /tmp/gce-movescript.env
echo "# Location of your rclone config file you wish to call" >> /tmp/gce-movescript.env
echo "RCLONE_CONFIG=/root/.config/rclone/rclone.conf"  >> /tmp/gce-movescript.env
echo "PROJECT_NAME=$project_name" >> /tmp/gce-movescript.env
echo "WEBHOOK=$webhook" >> /tmp/gce-movescript.env
echo "CHANNEL=$channel" >> /tmp/gce-movescript.env
echo "TRANSFERS=20"  >> /tmp/gce-movescript.env
echo "CHECKERS=60" >> /tmp/gce-movescript.env
echo "DRIVE_CHUNK_SIZE=64M" >> /tmp/gce-movescript.env

}

install_gcloud () {

export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-get update -y && sudo apt-get install google-cloud-sdk -y

gcloud init

}

spin_up_instance () {

gcloud beta compute instances create $INSTANCE_NAME --zone=$ZONE \
--machine-type=f1-micro --subnet=default --network-tier=PREMIUM --no-restart-on-failure \
--maintenance-policy=TERMINATE --preemptible  \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
--image=ubuntu-1604-xenial-v20181004 \
--image-project=ubuntu-os-cloud \
--boot-disk-size=10GB \
--boot-disk-type=pd-standard \
--boot-disk-device-name=$INSTANCE_NAME \
--metadata startup-script='curl https://raw.githubusercontent.com/zenjabba/install-gce-copier/master/install-copier.sh | sudo bash'

}


movefiles_gcloud () {

echo "Copying rclone.conf file to instance"
gcloud compute scp $RCLONE_CONFIG_FILE $INSTANCE_NAME:/root/.config/rclone/rclone.conf --zone=$ZONE
echo "Copying movescript.env to /root"
gcloud compute scp /tmp/gce-movescript.env $INSTANCE_NAME:/root/movescript.env --zone=$ZONE
echo "Copying collectionofremotes to /root"
gcloud compute scp /tmp/gce-collectionofremotes $INSTANCE_NAME:/root/collectionofremotes --zone=$ZONE

}

restart_instance () {

echo "Restarting Instance"
gcloud compute ssh --zone $ZONE $INSTANCE_NAME -- 'shutdown -r now'
}

# business end of the script

configure_rclone
get_endpoint_information
install_gcloud
spin_up_instance

echo "Sleeping 5 mins waiting for instance to complete spin up"
sleep 300

movefiles_gcloud 
restart_instance
