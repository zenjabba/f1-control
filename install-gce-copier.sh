#!/usr/bin/env bash
# 
# creates new install script.
# fixed missing }, but still not updateding the raw

update-upgrade () {

apt update -y  && apt upgrade -y

}

install-packages () {

# test update

apt install $1 -y

}

install-apps () {

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
    mkdir -p /root/.config/rclone/

}

create_scripts () {

echo "#!/bin/bash" >> /opt/runcopy.sh
echo "" >> /opt/runcopy.sh
echo "sleep 30" >> /opt/runcopy.sh
echo "/usr/bin/rclone sync --config=/root/.config/rclone/rclone.conf -v --checkers=50 --transfers=40 --drive-chunk-size=64M --stats=60s --ignore-existing --fast-list source:/ destination:/" >> /opt/runcopy.sh
echo "shutdown -h now" >> /opt/runcopy.sh

chmod a+x /opt/runcopy.sh

sed -i -e '$i \sleep 60 \n' /etc/rc.local
sed -i -e '$i \/opt/runcopy.sh &\n' /etc/rc.local

}

#
# This is where the "stuff" happens

update-upgrade
install-packages "unzip screen htop"
install-apps
create_scripts

