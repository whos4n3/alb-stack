#!/bin/sh

yum update -y
yum install -y httpd git
service httpd start
chkconfig httpd on
mkdir files 
cd files
git init && git pull https://github.com/whos4n3/methods.git && mv * /var/www/html
apachectl restart 