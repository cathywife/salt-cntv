#!/bin/bash

workDir="/var/log/.hist"
file="$workDir/`/bin/date '+%Y.%m.%d'`_history"

touch $file
chmod 666 $file
chattr +a $file

find $workDir/ -name "*_history" -size 0 -mtime +3 |while read file0
do
	chattr -a $file0
	rm -f $file0
done

sed -i "/^export HISTTIMEFORMAT/d" /etc/profile
