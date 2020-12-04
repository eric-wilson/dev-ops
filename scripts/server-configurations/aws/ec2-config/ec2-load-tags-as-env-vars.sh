#!/bin/bash -ex

################################################################################################################################
# Requirements

# AWS Permissions
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




################################################################################################################################
# log this process to /var/log/user-data.log
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

################################################################################################################################
# package manager update
sudo yum update -y
# / package manager update
################################################################################################################################


################################################################################################################################
# load tags as environment variables
sudo yum install -y jq

# add boot script which loads environment variables for all users
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
                        sed -E 's/^([^\s\t]+)[\s\t]+([^\n]+)$/export \1="\2"/g')
eval $export_statement



EOF

# run the script
sudo chmod +x /etc/profile.d/export_instance_tags.sh

# reload the profile so that the environment variables are available here
source ~/.bash_profile


# / load tags as environment variables
################################################################################################################################



