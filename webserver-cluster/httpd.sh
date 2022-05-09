#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo yum -y install wget

echo "Hello, World!" > /var/www/html/index.html

sudo systemctl enable httpd
sudo systemctl start httpd

