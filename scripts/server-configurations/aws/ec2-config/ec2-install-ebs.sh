#!/bin/bash -ex


################################################################################################################################
# log this process to /var/log/user-data.log
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1


sudo yum update -y
# using jq for parsing
sudo yum install -y jq


# configuration
region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
az=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .availabilityZone)   # az for the ebs
device="/dev/xvdf"          # volume we're going to attach (note you may need to change this if it's alreay in use)
mount_path="/app"           # change as necessary
ebs_volume_size=1           # size in GBs
ebs_volume_type="gp2"       # volume type
sleepy_time="20s"           # used as a 'wait' during this process

# set up our region for the cli
export AWS_DEFAULT_REGION=${region}

# create the ebs volume
# the 8th param is the volume-id, get it w/ awk which we'll need later
# there are other parameters that you can pass in, so update this script accordingly
# https://docs.aws.amazon.com/cli/latest/reference/ec2/create-volume.html
volume=$(aws ec2 create-volume \
        --volume-type ${ebs_volume_type}  \
        --size ${ebs_volume_size}   \
        --availability-zone ${az} \
        --output text | awk '{print $8}'
        )


# get the instance id of the EC2
instance_id=$(curl http://169.254.169.254/latest/meta-data/instance-id)


# sleep for a x seconds while we wait for the volume
sleep ${sleepy_time}


# attach the volume
aws ec2 attach-volume \
  --volume-id ${volume} \
  --instance-id ${instance_id} \
  --device ${device}


# give it time to attach
sleep ${sleepy_time}

# check to see if it's empty
sudo file -s ${device}

# format the volume
sudo mkfs -t ext4 ${device}

# give it time to do it's job
sleep ${sleepy_time}

# make our directory for the mount
sudo mkdir -p ${mount_path}

# mount it
sudo mount ${device} "${mount_path}/"


cd $mount_path

# see if we have nay issues
df -h .

# test it out (feel free to remove this)
sudo bash -c 'sudo  echo "hello my precious ebs" > hello-ebs.txt'

# automount on reboot
fs_tab="/etc/fstab"
sudo cp ${fs_tab} "${sf_tab}.bak"

sudo bash -c 'sudo  echo '"${device}  ${mount_path} ext4  defaults,nofail"' >> '"${fs_tab}"''

# reboot if we want to test it in the script
#sudo reboot


