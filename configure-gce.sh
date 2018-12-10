#!/bin/bash
# First run to set things up correctly
#

gcloud_billing_check () {
	billing=$(gcloud beta billing accounts list | grep "\<True\>")
	if [ "$billing" == "" ]; then 
	echo "Billing is not enabled on your account" 
	exit 2
}


gcloud_auth () {

sudo -s gcloud auth login --quiet $1

}

spin_up_instance_first () {

echo "/opt/f1-control/spinup.sh first-instance-name us-west2-a $1 to spin up your first instance"


}

gcloud_auth
gcloud_billing_check
spin_up_instance_first

exit
