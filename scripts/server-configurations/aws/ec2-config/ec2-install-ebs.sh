sudo yum update -y
# using jq for parsing
sudo yum install -y jq


# configuration
region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
az="${region}a"             # az for the ebs
device="/dev/xvdf"          # volume we're going to attach
mount_path="/app"  
ebs_volume_size=1
ebs_volume_type="gp2"

# set up our region for the cli
export AWS_DEFAULT_REGION=${region}

# create the ebs volume
# the 8th param is the volume-id, get it w/ awk
volume=$(aws ec2 create-volume \
        --volume-type ${ebs_volume_type}  \
        --size ${ebs_volume_size}   \
        --availability-zone ${az} \
        --output text | awk '{print $8}'
        )

# get the instance id
instance_id=$(curl http://169.254.169.254/latest/meta-data/instance-id)


# attach the volume
aws ec2 attach-volume \
  --volume-id ${volume} \
  --instance-id ${instance_id} \
  --device ${device}

# check to see if it's empty
sudo file -s ${device}

# format the volume
sudo mkfs -t ext4 ${device}

# make our directory for the mount
sudo mkdir -p ${mount_path}

# mount it
sudo mount ${device} "${mount_path}/"


cd $mount_path

# see if we have nay issues
df -h .

# test it out
sudo bash -c 'sudo  echo "hello my precious ebs" > hello-ebs.txt'

# automount on reboot
fs_tab="/etc/fstab"
sudo cp ${fs_tab} "${sf_tab}.bak"

sudo bash -c 'sudo  echo '"${device}  ${mount_path} ext4  defaults,nofail"' >> '"${fs_tab}"''

# reboot if we want to test it in the script
#sudo reboot


