#!/bin/bash

echo 0 > /tmp/gotIP

/sbin/ifconfig |sed -n '/inet addr/s/^[^:]*:\([0-9.]\{7,15\}\) .*/\1/p' |grep -v 127.0.0.1 |while read ip
do
        res=`dig +time=1 +tries=2 -x $ip |grep "PTR" |grep -v localhost |wc -l`
        if [ $res -ge 2 ]
        then
                echo $ip
                echo 1 > /tmp/gotIP
        fi
done

if [ `cat /tmp/gotIP` -eq 0 ]
then
        /sbin/ifconfig eth0 |sed -n '/inet addr/s/^[^:]*:\([0-9.]\{7,15\}\) .*/\1/p'
fi

rm -f /tmp/gotIP