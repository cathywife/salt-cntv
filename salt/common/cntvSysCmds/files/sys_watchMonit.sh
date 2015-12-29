#!/bin/bash
if [ ! -f /tmp/monit.lock ]
then
	#if [ "`cat /etc/salt/minion_id |md5sum |awk '{print $1}'`" != "`cat /root/.monit.id`" ]
	#then
	#	cat /etc/salt/minion_id |md5sum |awk '{print $1}' > /root/.monit.id
	#	/usr/bin/killall monit
	#	sleep 1
	#fi
	/usr/bin/killall -0 monit || /etc/init.d/monit restart
fi
