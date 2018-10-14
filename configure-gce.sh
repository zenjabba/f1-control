#!/bin/bash
# First run to set things up correctly
#

USERNAME=$1
INSTANCE_NAME="first-mover"
INSTANCE_ZONE="us-west2-a"

echo "This will create a control account with a different email address, and spin up your first instance with all the applications pre-installed."
echo "It will also add to your root CRONTAB a check for every hour to make sure your instance is up and running"

get_default_project () {

PROJECTID=$(gcloud projects list --uri)
PROJECTID=$(basename $PROJECTID)

}

gcloud_auth () {

gcloud auth login --quiet $USERNAME

}

run_as_root () {

if [[ $EUID = 0 ]]
then
	sleep 1
else
	echo "This script must be run as root"
   	exit 1
fi

}

generate_crontab () {

echo "0 * * * * /opt/f1-control/gcerevive.sh $INSTANCE_NAME $INSTANCE_ZONE $PROJECTID" | crontab -

}

spin_up_instance_first () {

/opt/f1-control/spinup.sh $INSTANCE_NAME $INSTANCE_ZONE

}


run_as_root
gcloud_auth
spin_up_instance_first
get_default_project
generate_crontab



exit
