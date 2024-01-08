#!/bin/bash

## ホスト名設定
HOSTNAME="datadog-dev-instance"
hostnamectl set-hostname ${HOSTNAME}

## HTTP設定
yum install -y httpd
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo `hostname` > /var/www/html/index.html

## Datadog Agent設定
dnf install -y libxcrypt-compat
#DD_API_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX DD_SITE="ap1.datadoghq.com" DD_APM_INSTRUMENTATION_ENABLED=host bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script_agent7.sh)"