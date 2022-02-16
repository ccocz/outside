#!/bin/bash

# Disclaimer: Below some commands need root privileges

echo "Updating essential packages"
apt update -y
apt upgrade -y
apt dist-upgrade -y
apt install -y apt-transport-https ca-certificates sudo

echo "Creating main user and adding to the groups"
useradd -m -d /home/sysadm -s /bin/bash sysadm
usermod -a -G sudo sysadm

echo "Enabling passwordless access"
echo "sysadm ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sysadm

echo "Setting correct file permissions"
chmod 0440 /etc/sudoers.d/sysadm
visudo -cf /etc/sudoers.d/sysadm

echo "Authorizing user for SSH access"
mkdir -p /home/sysadm/.ssh/

echo "Paste the cryptic text from your local SSH public key:"
key=`cat`
echo "$key" > /home/sysadm/.ssh/authorized_keys

chmod 700 /home/sysadm/.ssh
chmod 600 /home/sysadm/.ssh/authorized_keys
chown -R sysadm:sysadm /home/sysadm
