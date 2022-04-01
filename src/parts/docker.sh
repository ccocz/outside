#!/usr/bin/env bash

set -o errtrace -o nounset -o pipefail -o errexit

echo "Setting up Docker"

echo "Installing software common properties"
apt install software-properties-common -y

echo "Installing curl"
apt install curl -y

echo "Installing gnugpg"
apt install gnupg -y

echo "Adding apt repo key"
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
curl -fsSL https://download.docker.com/linux/debian/gpg -o /tmp/docker
gpg --dearmor /tmp/docker
cp /tmp/docker.gpg /etc/apt/trusted.gpg.d/docker.gpg
rm -rf /tmp/docker /tmp/docker.gpg

echo "Installing docker-ce"
apt update -y && apt install docker-ce aufs-tools- -y

echo "Setting default docker DNS"
echo "{
  \"dns\": [
     \"8.8.8.8\",
     \"8.8.4.4\",
     \"1.1.1.1\",
     \"1.0.0.1\"
  ]
}" >> /etc/docker/daemon.json

echo "Disabling iptables for Docker"
echo "DOCKER_OPTS=\"--iptables=false\"" >> /etc/default/docker

echo "Overriding Docker config"
mkdir -p /etc/systemd/system/docker.service.d/
echo "[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --iptables=false --ipv6 --bip 172.17.0.1/16 --fixed-cidr=172.17.0.0/16 --fixed-cidr-v6=2a01::/48
ExecStartPost=/usr/sbin/nft -f /etc/nftables.conf" > /etc/systemd/system/docker.service.d/override.conf

echo "Enabling and restarting Docker service"
systemctl daemon-reload
systemctl enable docker
service docker restart

echo "Adding sysadm to Docker group"
usermod -a -G docker sysadm

echo "Installing docker-compose"
apt install libffi-dev -y
apt install python3 python3-pip python3-setuptools -y
pip3 install docker-compose

echo "Finished Docker installation"