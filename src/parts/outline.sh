#!/usr/bin/env bash

set -o errtrace -o nounset -o pipefail -o errexit

echo "Starting OutlineVPN installation"

echo "Creating dedicated folder and creating config file"
mkdir -p outline/
cd outline/
echo "version: '3.8'

services:

  outline:
    image: morazow/outline-shadowsocks-server:1.3.5
    container_name: outline
    network_mode: host
    volumes:
      - \"./config.yml:/outline/config.yml:ro\"
    restart: unless-stopped
" > docker-compose.yml

echo "Creating users with passwords"

echo "keys:

  - id: mor
    port: 21
    cipher: chacha20-ietf-poly1305
    secret: u1337!
" >> config.yml

echo "Starting OutlineVPN"
docker-compose up -d
docker ps -a