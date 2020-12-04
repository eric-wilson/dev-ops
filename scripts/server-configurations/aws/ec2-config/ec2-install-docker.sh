#!/bin/bash -ex
# add user-data logs
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

start_time="$(date -u +%s.%N)"

current_user=$(whoami)
echo "executing commands as user: ${current_user}"
whoami

sudo yum update -y

#####################################################################################################################################################
# install docker & configure
sudo amazon-linux-extras install docker -y
#start docker
sudo service docker start
# make sure it statys running
sudo chkconfig docker on
#Add the ec2-user to the docker group so you can execute Docker commands without using sudo.
sudo usermod -a -G docker ec2-user
#get the latest docker-compose program
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
#fix permissions
sudo chmod +x /usr/local/bin/docker-compose


# / docker configure
#####################################################################################################################################################


#####################################################################################################################################################
# APP Setup

## Add application scripts here such as a docker-compose creation

sudo mkdir -p /app/docker
sudo cat > /app/docker/docker-compose.yml << 'EOF'
version: "3.7"

EOF

### switch to the correct directory 
#cd /app/docker/
### launch it
#docker-compose up -d
#or
#/usr/local/bin/docker-compose up -d

# / App Setup
#####################################################################################################################################################
