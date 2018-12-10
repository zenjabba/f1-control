#!/bin/bash
# First run to set things up correctly
#
# You need to have billing enabled on the account $1. 
# Some code stolen from https://github.com/Admin9705/PlexGuide.com-The-Awesome-Plex-Server/blob/1be63f22ea5ddc9efdd831732cc93744316a7748/menu/interface/gce/file.sh

gcloud_billing_check () {
	
	billing=$(gcloud beta billing accounts list | grep "\<True\>")
	if [ "$billing" == "" ]; then 
	echo "Billing is not enabled on your account $1" 
	exit 2

}

create_project () {
	date=`date +%m%d`
  	rand=$(echo $((1 + RANDOM + RANDOM + RANDOM + RANDOM + RANDOM + RANDOM + RANDOM + RANDOM + RANDOM + RANDOM )))
  	projectid="zendrive-$date-$rand"
  		gcloud projects create $projectid
  	sleep 1
}

gcloud_auth () {

sudo -s gcloud auth login --quiet $1

}

spin_up_instance_first () {

echo "/opt/f1-control/spinup.sh first-instance-name us-west2-a $1 to spin up your first instance"


}

gcloud_auth
gcloud_billing_check
create_project
spin_up_instance_first

exit
