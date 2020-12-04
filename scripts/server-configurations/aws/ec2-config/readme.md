# EC2 Installtion file

You can add this to the user data in order to prep an EC2 instance or run it manually on an existing EC2 instance

This shell scripts will:

1. Pull the EC2 Tags and load them as environment variables (a nice way to have configuraiton data)
2. Create a script to reload them the variables on reboots
3. Install Docke4
4. Install and configure cloud watch
5. Defines a starter place for your application docker compose file
6. Installs and configures s3fs, so that you can map a directory to S3.

## TODO's

1. Move the configuration scripts to S3 (e.g. docker-compose section).
2. After the S3 Mapping, look for additional scripts, pull them locally and the execute them.
3. Optionally, setup a script that will run on reboots.

## Requirements

This script, reads the EC2's tags to populate most of the variables it references, you will need to add those EC2 tags in order for this to run correctly.

### Tags

The primary tags you should create and populate

|Tag |Description |
| --- | --- |
|ENVIRONMENT|dev, qa, uat, prod, etc - often used in your docker compose files|
|BUCKET_NAME|The bucket name we'll map to|
|PROJECT|A project name, used to mapp CloudWatch logs groups to|


### Permissions

In addition, you will need to have the correct permissions in order to:

1. Read the Tags
2. Start the Cloudwatch agent

### Roles

Create a new rolw and add the following permissions.

```bash
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

## AmazonS3FullAccess (this should be brought down to the specific S3 Access on the bucket configured ~ least privleged, etc)
## CloudWatchAgenServerPolicy (to write the logs)
## AmazonSSMFullAccess (to remote connect from the AWS console) -> you may not need full access. I still need to play around to see what the min privelge is
## AmazonEC2FullAccess (or tailor to your needs)
```