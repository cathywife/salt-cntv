#!/bin/bash
if [ ! -f /tmp/monit.lock ]
then
	/usr/bin/killall -0 monit || /usr/local/monit/bin/monit -c /usr/local/monit/etc/monitrc
fi
