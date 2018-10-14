#!/usr/bin/env bash

update-upgrade () {

apt update -y  && apt upgrade -y

}

install-packages () {

# test update

apt install $1 -y

}

install-rclone () {

#
# install rclone
#

local DOWNLOAD_LINK="https://beta.rclone.org/rclone-beta-latest-linux-amd64.zip"
local RCLONE_ZIP="rclone-beta-latest-linux-amd64.zip"
local UNZIP_DIR="/tmp/rclone-temp"

curl -O $DOWNLOAD_LINK
mkdir -p $UNZIP_DIR

/usr/bin/unzip -a $RCLONE_ZIP -d $UNZIP_DIR
cd $UNZIP_DIR/*
cp rclone /usr/bin/rclone.new
    chmod 755 /usr/bin/rclone.new
    chown root:root /usr/bin/rclone.new
    mv /usr/bin/rclone.new /usr/bin/rclone
    #manuals
    mkdir -p /usr/local/share/man/man1
    cp rclone.1 /usr/local/share/man/man1/
    mandb

}

config-rclone () {

mkdir -p /root/.config/rclone/
# rclone.conf needs to be pushed from the users desktop using "gcloud compute scp $RCLONE_CONFIG_FILE $INSTANCE_NAME:/root/.config/rclone/rclone.conf --zone=$ZONE"
# this will be part of the local script. 

}

general-process () {

cd /opt
git clone https://github.com/zenjabba/zendrivescripts
chmod a+x /opt/zendrivescripts/rocketpush.sh
chmod a+x /opt/zendrivescripts/movesource

}

final-process () {

# this runs when everything is finished, and leaves the box waiting for the client to upload the specific files
sed -i -e '$i \/opt/zendrivescripts/movesource /root/collectionofremotes &\n' /etc/rc.local

}
#
# This is where the "stuff" happens

update-upgrade
install-packages "unzip"
install-rclone
config-rclone
general-process

final-process
