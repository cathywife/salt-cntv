#!/bin/bash

set -e
set -x

cd /tmp/src

rm -f /etc/yum.repos.d/*
echo '[CentOS-Base]
name=CentOS-$releasever-$basearch-Base
baseurl=http://10.64.5.100/repo/centos/$releasever/os/$basearch/
enabled=1
gpgcheck=0' > /etc/yum.repos.d/cntvInternal.repo

yum install -y wget

wget http://10.64.5.100/cntvInternal.repo -O /etc/yum.repos.d/cntvInternal.repo

echo -e "HOSTNAME=localhost.localdomain\nNETWORKING=yes" > /etc/sysconfig/network

yum install -y openssh-server openssh-clients vixie-cron supervisor

sed -i -e 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
echo root | passwd --stdin root

\cp supervisord.conf /etc/supervisord.conf

cd /
yum clean all
rm -rf /var/tmp/yum-root* /tmp/src

