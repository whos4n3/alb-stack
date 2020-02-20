#!/bin/sh

yum update -y
yum install -y httpd
echo "Welcome to Whosane's Website. Look around and enjoy" > /var/www/html/index.html
service httpd start
chkconfig httpd on

