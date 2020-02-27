#!/bin/sh

yum update -y
yum install -y httpd git
mkdir files 
cd files
git init && git pull https://github.com/whos4n3/methods.git && mv * /var/www/html
rm -f /var/www/html/index.html
echo "Welcome to Whosane's Website. Look around and enjoy" > /var/www/html/index.html
service httpd start
chkconfig httpd on