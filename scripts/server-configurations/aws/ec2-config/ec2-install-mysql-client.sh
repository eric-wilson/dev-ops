#!/bin/sh

sudo yum install -y https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
sudo yum install -y mysql-community-client


# installs maria db
sudo yum update -y
sudo yum install mysql

# doesn't seem to work
sudo yum install mysql