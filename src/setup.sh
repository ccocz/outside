#!/usr/bin/env bash

# Nota bene: Below some commands need root privileges

set -o errtrace -o nounset -o pipefail -o errexit

# Init setup

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

echo "Paste the cryptic text from your local SSH public key(s) and CTRL+D:"
key=`cat`
echo "$key" > /home/sysadm/.ssh/authorized_keys

chmod 700 /home/sysadm/.ssh
chmod 600 /home/sysadm/.ssh/authorized_keys
chown -R sysadm:sysadm /home/sysadm

echo "Backing up old SSH config file and replacing with new one"
mv /etc/ssh/sshd_config ../conf/sshd_config.bak
cp ../conf/sshd_config /etc/ssh/

echo "Restarting SSH service"
service sshd restart

echo "Stopping and removing iptables"
service iptables stop || true
systemctl disable iptables || true
apt remove --purge --auto-remove iptables -y

echo "Installing nftables"
apt update -y && apt install nftables -y

echo "Backing up nftables config file"
mv /etc/nftables.conf ../conf/nftables.conf.bak

cp ../conf/nftables.conf /etc/

echo "Finished initial set-up"

chmod +x ./parts/docker.sh && ./parts/docker.sh

chmod +x ./parts/outline.sh && ./parts/outline.sh

curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
chmod +x openvpn-install.sh
mv openvpn-install.sh parts
./parts/openvpn-install.sh

echo "Enabling and starting nftables (your SSH session might halt)"
systemctl enable nftables
service nftables start
