#!/bin/bash

sudo yum update -y
# using jq for parsing
sudo yum install -y jq

# instead of hard-coding these values, you could add them as environment vars
# see loading environment vars from tags
main_path="company_name/app_name"   
environment="dev"          
parameter_store_prefix="/${main_path}/${environment}"

# note to execute this statement, the EC2 instance will need the correct permissions
# AmazonSSMReadOnlyAccess is appropriate
# add the appropriate policy to the role attached to the EC2 instance#
# the split("/")[-1] will grab the last parameter as the "name" for the variable
# all varable names are converted to upper case for ENV consistency
export_statement=$(aws ssm get-parameters-by-path \
    --path "${parameter_store_prefix}" \
    --region us-east-1 --recursive \
    --with-decrypt \
    | jq -r '.Parameters[] | "export " + (.Name | split("/")[-1] | ascii_upcase | gsub("-"; "_")) + "=\"" + .Value + "\""' \
    )


# eval the statements to load them into memory
# the above script addthem in a pattern of
# export parameter_name=parameter_value
eval $export_statement

# export them to a file
sudo cat -s > /etc/profile.d/load_ssm_parameters.sh << EOF

$export_statement

EOF

# make sure the script can execute when/if a reboot happens
chmod +x /etc/profile.d/load_ssm_parameters.sh


