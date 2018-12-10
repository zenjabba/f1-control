# f1-control

To install f1-control on your f1-gce server (using Ubuntu 16.04 LTS) (which should be setup on your @gmail account because it's free and you never want it to go away). We will create a google spreadsheet to use as "small database" which allows us to keep track of information. This is called %spreadsheetname%

1. `cd /opt`

2. `sudo git clone https://github.com/zenjabba/f1-control`

3. `sudo f1-control/configure-gce.sh email@address`

    The email address should be the email you have the free $300 credit on, and should be fully configured waiting for new instances. We perform some basic checks against your account to make sure you can run things correctly
