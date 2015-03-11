#!/bin/bash
ip=`/usr/local/cntv/sys_getAdminIP.sh`
hostname=`dig -x $ip @10.70.63.152 |grep "PTR" |grep -v "^;" |awk '{print $5}' |sed "s/.$//g" |grep -v "localhost" |head -n 1`
[ "$hostname" != "" ] && echo $hostname || exit 1