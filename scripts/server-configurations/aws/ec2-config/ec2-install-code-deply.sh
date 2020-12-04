#!/bin/bash -ex


################################################################################################################################
# log this process to /var/log/user-data.log
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

################################################################################################################################
# package manager update
sudo yum update -y
# / package manager update
################################################################################################################################


################################################################################################################################
# code deploy agent
sudo yum install ruby -y
sudo yum install wget -y
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install

# give execution permissions
chmod +x ./install

# run it
./install auto

sudo service codedeploy-agent status
# /code deploy agent
################################################################################################################################