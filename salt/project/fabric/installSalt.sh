#安装salt-minion#
unset http_proxy https_proxy ftp_proxy RSYNC_PROXY
adminIP=`/sbin/ifconfig |grep "inet .*cast" |sed -n 's/.*\(\inet addr:\|inet \)\(\([0-9.]\{7,15\}\)\) .*/\2/p' |grep -P "^192|^10" |sort |head -n 1`
sed -i "/^## base start ##$\|saltMaster$\|centralControl$\|^## base end ##$/d" /etc/hosts
echo -e "## base start ##\n10.70.58.196\tsaltMaster\n10.70.63.131\tcentralControl\n## base end ##" >> /etc/hosts

#[ -f /etc/salt/minion ] && { yum remove -y zeromq salt-minion; rm -rf {/etc/salt/pki,/etc/salt-cntv/pki} 2> /dev/null; } 

rm -f /etc/yum.repos.d/*
curl http://centralControl/webServer/cntvInternal.repo -o /etc/yum.repos.d/cntvInternal.repo

yum install -y --enablerepo=cntvInternal zeromq zeromq-devel python-msgpack python-zmq python26-zmq python26-distribute salt

curl http://10.70.63.131/webServer/salt-minion-cntv/salt-minion-cntv -o /usr/bin/salt-minion-cntv
curl http://10.70.63.131/webServer/salt-minion-cntv/salt-minion-cntv.init.d -o /etc/rc.d/init.d/salt-minion-cntv
[ -f /usr/bin/python2.6 ] || sed -i "s/^#\!\/usr\/bin\/python2\.6/#\!\/usr\/bin\/python2/g" /usr/bin/salt-minion-cntv
chmod 755 {/usr/bin/salt-minion-cntv,/etc/rc.d/init.d/salt-minion-cntv}
mkdir -p {/etc/salt-cntv,/var/cache/salt-cntv}
\cp /etc/salt-cntv/minion /etc/salt-cntv/minion.bak

echo "master: saltMaster
master_port: 4606

id: $adminIP

pki_dir: /etc/salt-cntv/pki
cachedir: /var/cache/salt-cntv
sock_dir: /var/run/salt/minion-cntv
log_file: /var/log/salt/minion-cntv
pidfile: /var/run/salt-minion-cntv.pid

log_level: info

dns_check: false

backup_mode: minion
" > /etc/salt-cntv/minion

systemctl daemon-reload 2>/dev
service salt-minion-cntv restart
chkconfig salt-minion-cntv on
#完成#