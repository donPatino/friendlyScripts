#!/bin/bash
# Created by Pablo Patino 2020
# Last revised Feb 2020

## Verify this script is run by root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# TODO: Add a message no notify the user about SG etc.
# TODO: Extract instance info from meta-data

main () {
  # Yun update
  yum update -y &&

  # Install and configure Apache
  yum install httpd -y &&
  systemctl enable httpd &&
  systemctl start httpd &&
  
  # Configure ssl based on https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/SSL-on-amazon-linux-2.html
  # Install mod_ssl module for Apache
  sudo yum install -y mod_ssl
  sudo /etc/pki/tls/certs/make-dummy-cert /etc/pki/tls/certs/localhost.crt
  
  #Server may fail to start
  # Need to figure out how to comment out a line
  # sed -e '/SSLCertificateKeyFile \/etc\/pki\/tls\/private\/localhost.key/ s/^#*/#/' -i /etc/httpd/conf.d/ssl.conf

  
}

main