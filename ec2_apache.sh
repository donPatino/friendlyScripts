#!/bin/bash
# Created by Pablo Patino 2020
# Last revised Feb 2020

## Verify this script is run by root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   echo "Run `sudo su` then execute this script"
   exit 1
fi

# TODO: Add a message no notify the user about SG etc.

main () {
  # Yun update
  yum update -y &&

  # Install and configure Apache
  yum install httpd -y &&
  systemctl enable httpd &&
  systemctl start httpd &&
  
  # Configure ssl based on https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/SSL-on-amazon-linux-2.html
  # Install mod_ssl module for Apache
  sudo yum install -y mod_ssl &&
  sudo /etc/pki/tls/certs/make-dummy-cert /etc/pki/tls/certs/localhost.crt &&
  # This file does not exist and it causes the server not to start.
  # Comment out line
  sed -i-$(date +%s).bak  "s|^\(SSLCertificateKeyFile /etc/pki/tls/private/localhost.key\)$|#\1|g" /etc/httpd/conf.d/ssl.conf &&
  systemctl restart httpd &&
  
  # Obtain public IP
  public_ip=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`

  # Simple IP regex
  regex='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'
  if [[ ${public_ip} =~ ${regex} ]];
  then
      motd="Apache no SSL: http://${public_ip}/ & Apache self-signed SSL: https://${public_ip}/" &&

      # Disable motd auto overwrite
      update-motd --disable && 

      # Backup current motd
      cp -v /var/lib/update-motd/motd{,.$(date +%s).bak} &&

      # Append endpoints to motd
      echo $motd >> /var/lib/update-motd/motd &&

      ## NOTE: There is still an issue with motd being overwritten when run as EC2 launch script
  else
      echo "Instance does not have a public IP"
  fi
}

main