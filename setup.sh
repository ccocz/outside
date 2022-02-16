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

echo "Backing up old SSH config file and replacing with new one"
mv /etc/ssh/sshd_config sshd_config.bak
cp sshd_config /etc/ssh/

echo "Restarting SSH service"
service sshd restart

echo "Stopping and removing iptables"
service iptables stop
systemctl disable iptables
apt remove --purge --auto-remove iptables -y

echo "Installing nftables"
apt update -y && apt install nftables -y

echo "Backing up nftables config file"
mv /etc/nftables.conf nftables.conf.bak

cp nftables.conf /etc/

echo "Enabling and starting nftables"
systemctl enable nftables
service nftables start
