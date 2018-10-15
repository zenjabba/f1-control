#!/bin/bash
# First run to set things up correctly
#

gcloud_auth () {

sudo -s gcloud auth login --quiet $USERNAME

}

spin_up_instance_first () {

echo "/opt/f1-control/spinup.sh first-instance us-west2-a" to spin up your first instance

}

gcloud_auth
spin_up_instance_first

exit
