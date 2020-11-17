#!/bin/bash

# This script configures an Ubuntu system with NGINX rtmp streaming. Note this script makes changes to your machine configuration.
# Use with care and backup any important data or configs before running.
set -euo pipefail
IFS=$'\n\t'

apt-get update -y
apt-get install -y sudo

SUDO="/usr/bin/sudo"
"${SUDO}" apt-get install -y \
	git \
	build-essential \
	ffmpeg \
	libpcre3-dev \
       	libssl-dev \
	zlib1g-dev \

git clone https://github.com/arut/nginx-rtmp-module.git 

git clone https://github.com/nginx/nginx.git 

pushd nginx

./auto/configure \
	--add-module=../nginx-rtmp-module \
	--with-http_ssl_module --with-cc-opt="-Wimplicit-fallthrough=0"

make

sudo make install

sudo /usr/local/nginx/sbin/nginx -v

popd

# TODO: see if file exists first
TMPFILE=$(mktemp /tmp/nginx_rtmp_script.XXXXXX)
cat << EOF >> "${TMPFILE}"
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t
ExecStart=/usr/local/nginx/sbin/nginx -g "pid /var/run/nginx.pid;"
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT '$MAINPID'
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
sudo mv "${TMPFILE}" /etc/systemd/system/nginx.service

sudo systemctl daemon-reload
sudo systemctl restart nginx
