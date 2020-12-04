#!/bin/bash -ex


################################################################################################################################
# log this process to /var/log/user-data.log
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1



################################################################################################################################
# package manager update
sudo yum update -y
# / package manager update
################################################################################################################################

#APACHE_ROOT_DIR="/app-vol/www/html/"
#APACHE_LOG_DIR="/app-vol/www/logs"


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
  log_dir="/app/www/log/"
  sudo mkdir -p ${log_dir}
  # set the variable
  export APACHE_LOG_DIR=${log_dir}
  # write it out to the file to persist on reboots
  echo "export APACHE_LOG_DIR=${APACHE_LOG_DIR}" >> /etc/profile.d/apache_environment_var.sh
fi

if [ -z $APACHE_ROOT_DIR ]
then
  #make the dir
  sudo mkdir -p /app/www/html/
  # set the variable
  export APACHE_ROOT_DIR="/app/www/html/"
  # write it out to the file to persist on reboots
  echo "export APACHE_ROOT_DIR=${APACHE_ROOT_DIR}" >> /etc/profile.d/apache_environment_var.sh
fi

# create the home page
sudo cat -s > "${APACHE_ROOT_DIR}/index.html" << EOF
<html>
<body>Hello AWS World</body>
</html>
EOF


# set up the custom config
sudo cat -s > /etc/httpd/conf.d/custom-configure.conf << EOF
<VirtualHost *:*>
    RequestHeader set "X-Forwarded-Proto" expr=%{REQUEST_SCHEME}
</VirtualHost>

<VirtualHost *:80>    
    ErrorLog ${APACHE_LOG_DIR}app-error.log
    CustomLog ${APACHE_LOG_DIR}app-custom.log common
    DocumentRoot ${APACHE_ROOT_DIR}
    <Directory ${APACHE_ROOT_DIR}>
            Options FollowSymLinks
            AllowOverride All
            Require all granted
      </Directory>
</VirtualHost>
EOF


sudo service httpd configtest
sudo systemctl restart httpd
sudo systemctl enable httpd

# / configure apache
################################################################################################################################


# display the mount and path to the file
cd ${APACHE_ROOT_DIR}
pwd; ls -l


echo "user data install - complete"





