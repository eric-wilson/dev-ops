#!/bin/bash -ex
# add user-data logs
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

start_time="$(date -u +%s.%N)"

current_user=$(whoami)
echo "executing commands as user: ${current_user}"
whoami

sudo yum update -y

#####################################################################################################################################################
# scripts to export EC2 instance tags to environment variables

# using jq for parsing
sudo yum install -y jq

# add boot script which loads environment variables
cat > /etc/profile.d/export_instance_tags.sh << 'EOF'
#!/bin/bash
# fetch instance info
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
# export instance tags
export_statement=$(aws ec2 describe-tags --region "$REGION" \
                        --filters "Name=resource-id,Values=$INSTANCE_ID" \
                        --query 'Tags[?!contains(Key, `:`)].[Key,Value]' \
                        --output text | \
                        awk  '{ 
                              x=""
                              for(i=1;i<=NF;i++) { 
                                if(i==1) {
                                  x="export " toupper($i)"=""\"";
                                }else {
                                  # add the space
                                  if(i>2) x=x" ";
                                  x=x$i;
                                } 
                                # close it off and print it
                                if(i==NF) { x=x"\""; print x; }      
                              }; 
                          }' 
                        )
eval $export_statement
# export instance info
export INSTANCE_ID
export REGION
EOF




# run the script
sudo chmod +x /etc/profile.d/export_instance_tags.sh

# reload the profile so that the environment variables are available here
source ~/.bash_profile

echo "Environment: ${ENVIRONMENT}"
echo "Bucket Name: ${BUCKET_NAME}"
echo "Project: ${PROJECT}"


# / scripts to export EC2 instance tags to environment variables
#####################################################################################################################################################






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
# cloud watch agent
#
#
sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
# install the agent
sudo rpm -U ./amazon-cloudwatch-agent.rpm

# start it - it seems i need to start it one time before creating my config file below
# if i create the file first, it seems to get deleted on the intial start
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a start

# define the path
readonly readonly CLOUD_WATCH_AGENT_CONFIG_PATH="/opt/aws/amazon-cloudwatch-agent/etc"

# may need create the directory (the install or start should have done that)
#mkdir -p $CLOUD_WATCH_AGENT_CONFIG_PATH

# define the cloudwatch agent config file
readonly CLOUD_WATCH_AGENT_CONFIG_FILE_TEMP="${CLOUD_WATCH_AGENT_CONFIG_PATH}/temp-config.json"
readonly CLOUD_WATCH_AGENT_CONFIG_FILE="${CLOUD_WATCH_AGENT_CONFIG_PATH}/amazon-cloudwatch-agent.json"

echo "Making Primary Config File (temp and final path)"
echo "${CLOUD_WATCH_AGENT_CONFIG_FILE_TEMP}"
echo "${CLOUD_WATCH_AGENT_CONFIG_FILE}"



# define the contents of the file. use the temp file incase the main file gets wiped out
# __PROJECT_NAME__ will get replaced in the next section
sudo cat > "${CLOUD_WATCH_AGENT_CONFIG_FILE_TEMP}" << 'EOF'
{  
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log",
            "log_group_name": "__PROJECT_NAME__/web/cloudwatch-agent",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/__PROJECT_NAME__/*",
            "log_group_name": "__PROJECT_NAME__/web/app",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          }
        ]
      }
    },
    "log_stream_name": "my_log_stream_name",
    "force_flush_interval" : 15
  }
}
EOF



# this should be loaded as an environment variable, or you can set it here
if [ -z $PROJECT ]
then
 # not found so set the variable to one of your choosing
 export PROJECT="project_name_unknown"
 # write it out to the file to persist on reboots
 echo "export PROJECT=${PROJECT}" >> /etc/profile.d/export_instance_tags.sh
fi

# replace the __PROJECT_NAME__ with the variable $project value
sed "s/__PROJECT_NAME__/$PROJECT/g" "${CLOUD_WATCH_AGENT_CONFIG_FILE_TEMP}" > "${CLOUD_WATCH_AGENT_CONFIG_FILE}"

# restart it to load the new configuration
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a stop
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a start

# run a status check, so it will appear in the user-data logs
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status

#
#
# / cloud watch agent
#####################################################################################################################################################





#####################################################################################################################################################
# Requirements

# AWS Permissions to Read Tags, which pushes them into Environment Variables
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {    
#       "Effect": "Allow",
#       "Action": [ "ec2:DescribeTags"],
#       "Resource": ["*"]
#     }
#   ]
# }

## AmazonS3FullAccess (this should be brought done to the specific S3 Access on the bucket configured)
## CloudWatchAgenServerPolicy (to write the logs)
## AmazonSSMFullAccess (to remote connect) -> you may not need full access
## AmazonEC2FullAccess (not sure if this is needed)

# / Requirements
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

# / App Setup
#####################################################################################################################################################




#####################################################################################################################################################
# S3 Mounting
# install epel (a required package for 3sfs-fuse)
sudo amazon-linux-extras install epel -y
# install s3fs-fuse to mount s3 drives to our instance
sudo yum install s3fs-fuse -y
# make a directory for the media files, we're going to map to S3
if [ -z $S3_MEDIA_DIR ]
then
 # not found so set the variable to one of your choosing
 export S3_MEDIA_DIR="/app/s3/media"
 # write it out to the file to persist on reboots
 echo "export S3_MEDIA_DIR=${S3_MEDIA_DIR}" >> /etc/profile.d/export_instance_tags.sh
fi

sudo mkdir -p $S3_MEDIA_DIR

# sudo s3fs bucket-name local directory add the role, were using, allow the local directory to have files in it
# $ROLE_NAME is being pulled from an environment variable, which is loaded via the EC2 tags with a matching tag name
# and value contains the ROLE_NAME
sudo s3fs $BUCKET_NAME $S3_MEDIA_DIR -o iam_role=$ROLE_NAME -o allow_other -o nonempty
# / S3 Mounting
#####################################################################################################################################################

# copy the data over from s3 so we can load it into sql-server
sudo chown -R  ec2-user /app/db/bk
sudo cp ${S3_MEDIA_DIR}/*.* /app/db/bk/

echo "Launch Script Completed"
end_time="$(date -u +%s.%N)"

elapsed="$(bc <<<"$end_time-$start_time")"
echo "Total of $elapsed seconds elapsed for script to run"