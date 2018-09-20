#!/usr/bin/env bash

ssh -i ~/.ssh/$PRIKEY ubuntu@$GCP_IP_ADDRESS 'rm -Rf /home/ubuntu/resources && rm -Rf /home/ubuntu/scripts && mkdir /home/ubuntu/resources';
scp -i ~/.ssh/$PRIKEY -r ./scripts ubuntu@$GCP_IP_ADDRESS:/home/ubuntu/scripts
scp -i ~/.ssh/$PRIKEY -r ./resources ubuntu@$GCP_IP_ADDRESS:/home/ubuntu

ssh -i ~/.ssh/$PRIKEY ubuntu@$GCP_IP_ADDRESS 'cd /home/ubuntu/scripts; bash run_gcp.sh'

exit 0
