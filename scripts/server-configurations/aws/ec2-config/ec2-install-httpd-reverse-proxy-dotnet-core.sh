#!/bin/bash -ex


################################################################################################################################
# log this process to /var/log/user-data.log
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1


################################################################################################################################
# NOTES
# use the amazon linux 2 ami (with .netcore)
# be sure to search for this one the default amazon linux 2 ami doesn't have .netcore installed
# 
# You can use this to create an AMI or simply load it via the user data
# if you load it via user-data, then it will take a little longer for the server to come-online
# however, you will alwasy have a fresh ami
################################################################################################################################



################################################################################################################################
# package manager update
sudo yum update -y
# / package manager update
################################################################################################################################




################################################################################################################################
# apache
sudo yum -y install httpd mod_ssl
sudo systemctl start httpd
sudo systemctl enable httpd
sudo usermod -a -G apache ec2-user
# / apache
################################################################################################################################




################################################################################################################################
# configure apache
if [ -z $APACHE_LOG_DIR ]
then
  #make the dir
  sudo mkdir -p /var/log/apache/
  # set the variable
  export APACHE_LOG_DIR="/var/log/apache/"
  # write it out to the file to persist on reboots
  echo "export APACHE_LOG_DIR=${APACHE_LOG_DIR}" >> /etc/profile.d/apache_environment_var.sh
fi

# https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/linux-apache?view=aspnetcore-3.1
# NOTE: the alb should be doing ssl termination, which means we should only be getting port 80 traffic behind the 
#       the loadbalancer, so we shouldn't need to set up any SSL configurations



sudo cat -s > /etc/httpd/conf.d/dotnet-configure.conf << EOF
<VirtualHost *:*>
    RequestHeader set "X-Forwarded-Proto" expr=%{REQUEST_SCHEME}
</VirtualHost>

<VirtualHost *:80>
    ProxyPreserveHost On
    ProxyPass / http://127.0.0.1:5000/
    ProxyPassReverse / http://127.0.0.1:5000/    
    ErrorLog ${APACHE_LOG_DIR}dotnet-app-error.log
    CustomLog ${APACHE_LOG_DIR}dotnet-app-access.log common    
</VirtualHost>
EOF


sudo service httpd configtest
sudo systemctl restart httpd
sudo systemctl enable httpd

# / configure apache
################################################################################################################################




echo "user data install - complete"





