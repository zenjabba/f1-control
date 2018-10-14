#!/bin/bash
# User Configuration Section
# This is the user configuration section
# $1 = Name of Instance
# $2 = Zone to run it in


MACHINE_TYPE="n1-standard-8"

if [ "$#" -ne 0 ]
then
	echo "This script can take 3 variables ie, $0 instance_name zone"
else
	sleep 1
fi

INSTANCE_NAME=$1
ZONE=$2

spin_up_instance () {

gcloud beta compute instances create $INSTANCE_NAME --zone=$ZONE \
--machine-type=$MACHINE_TYPE --subnet=default --network-tier=PREMIUM --no-restart-on-failure \
--maintenance-policy=TERMINATE --preemptible  \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
--image=ubuntu-1604-xenial-v20181004 \
--image-project=ubuntu-os-cloud \
--boot-disk-size=10GB \
--boot-disk-type=pd-standard \
--boot-disk-device-name=$INSTANCE_NAME \
--metadata startup-script='curl https://raw.githubusercontent.com/zenjabba/install-gce-copier/master/install-copier.sh | sudo bash'

}


# business end of the script


spin_up_instance
