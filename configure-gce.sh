# First run to set things up correctly

USERNAME=$1

echo "This will create a control account with a different email address"

gcloud_auth () {

gcloud auth login $USERNAME

}

run_as_root () {

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

}

spin_up_instance_first () {

/opt/f1-control/spinup.sh

}

run_as_root 
gcloud_auth
spin_up_instance_first

exit

