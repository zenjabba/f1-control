#!/bin/bash
# GCE Instance Revive Script
# general GCE startup script
# Initial version from RXWatcher
#  $1 INSTANCE, $2 ZONE $3 PROJECTID


ZONE=$2
INSTANCE=$1
PROJECTID=$3
LOGFILE="/var/log/gcerevive/$PROJECTID-$INSTANCE"

check_status () {

echo "$(date "+%d.%m.%Y %T") Checking $INSTANCE Status.."
PRESTATUS=$(/usr/bin/gcloud compute instances describe $INSTANCE --project=$PROJECTID --zone=$ZONE | grep  "status")
STATUS=${PRESTATUS:7}
if [ $STATUS = "RUNNING" ]; then
        echo "$(date "+%d.%m.%Y %T") $INSTANCE Instance is Running at"$(/usr/bin/gcloud compute instances describe $INSTANCE --project=$PROJECTID --zone=$ZONE| grep natIP | cut -d':'  -f2) |tee -a $LOGFILE
        exit
fi

if [ $STATUS = "TERMINATED" ]; then
        echo "$(date "+%d.%m.%Y %T") $INSTANCE Instance is NOT Running" | tee -a $LOGFILE
        echo "$(date "+%d.%m.%Y %T") Sending Instance startup command for $INSTANCE" | tee -a $LOGFILE
        echo "$(date "+%d.%m.%Y %T") Waiting for services to come online....." | tee -a $LOGFILE
        /usr/bin/gcloud compute instances start --quiet $INSTANCE --project=$PROJECTID --zone=$ZONE
        echo "$(date "+%d.%m.%Y %T") $INSTANCE started." | tee -a $LOGFILE
fi

}

check_if_logdir_exists () {

if [ ! -d "/var/log/gcerevive/" ]; then
  mkdir -p /var/log/gcerevive/
fi

}

get_default_project () {

PROJECTID=$(gcloud projects list --uri)
PROJECTID=$(basename $PROJECTID)

}

project_id_process () {

if [ $PROJECTID = "" ]; then
	echo "Getting default PROJECTID"
	get_default_project
else
	echo "" > /dev/null
fi

}

project_id_process
check_if_logdir_exists
check_status

exit
