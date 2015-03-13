#!/bin/bash
#安装salt-minion#
adminIP=`/sbin/ifconfig |sed -n '/inet addr/s/^[^:]*:\([0-9.]\{7,15\}\) .*/\1/p' |grep -P "^192|^10" |sort |head -n 1`
sed -i "/saltMaster$\|centralControl$/d" /etc/hosts
echo -e "10.70.58.196\tsaltMaster\n10.70.63.131\tcentralControl" >> /etc/hosts

[ -f /etc/salt/minion ] && { yum remove -y zeromq salt-minion; rm -rf /etc/salt/pki; } 

rm -f /etc/yum.repos.d/*
curl http://centralControl/webServer/cntvInternal.repo > /etc/yum.repos.d/cntvInternal.repo

yum groupinstall -y base
yum install -y --enablerepo=cntvInternal zeromq zeromq-devel python-zmq python26-zmq python26-distribute salt-minion
\cp /etc/salt/minion /etc/salt/minion.bak
echo "master: saltMaster
backup_mode: minion
log_file: /var/log/salt/minion
log_level: info" > /etc/salt/minion
echo "$adminIP" > /etc/salt/minion_id
service salt-minion restart
chkconfig salt-minion on
#完成#