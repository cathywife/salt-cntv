#!/bin/bash

svn up --username xxxxxxxxxx --password xxxxxxxxxxxx --non-interactive /data/svnClient/salt-cntv
sh convertServerList.sh

if [ $# -ge 1 ]
then
	keys=`cat $1 |grep -v "^$\|^#" |tr -t '\n' ' '`
	test=`[ "$2" = "test" ] && echo "True" || echo "False"`
else
	keys=`/usr/bin/salt-key -l unaccepted |grep -v "^Unaccepted Keys:$"`
	if [ `echo $keys |wc -c` -le 1 ]
	then
		keys=`/usr/bin/salt-key -l accepted |grep -v "^Accepted Keys:$"`
	else
		/usr/bin/salt-key -A -y
	fi
fi

function wait()
{
	for t in `seq 1 $1`
	do
		echo -n .
		sleep 1
	done
	echo
}

echo $keys |sed "s/ /,/g" |while read ips
do
	echo "running: saltutil.refresh_pillar $ips"
	salt -L "$ips" -b 5 saltutil.refresh_pillar
	wait 5
	echo "running: common.salt-minion $ips"
	salt -L "$ips" state.sls common.salt-minion
	wait 5
	echo "running: common.highstate $ips"
	salt -L "$ips" -b 5 state.highstate test=$test
done