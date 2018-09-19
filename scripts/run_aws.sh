#!/usr/bin/env bash

set -x

export AWS_KEY=aws_key

sudo sh -c "echo ''  >> /etc/hosts"
sudo sh -c "sudo echo '127.0.1.1 '`hostname`  >> /etc/hosts"

sed -i "s|USER=vagrant|USER=ubuntu|g" /home/ubuntu/scripts/churchinfo.sh
sed -i "s|SRC_DIR=/vagrant|SRC_DIR=/home/ubuntu|g" /home/ubuntu/scripts/churchinfo.sh

cd /home/ubuntu/scripts
bash churchinfo.sh aws

exit 0
