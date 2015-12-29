#!/bin/bash

#SET VAR
	username=`who -u am i 2>/dev/null| awk '{print $1}'`
	userIP=`who -u am i 2>/dev/null| awk '{print $NF}'|sed -e 's/[()]//g'`
	histDir=/var/log/.hist
	CAT=`/usr/bin/which cat`
	DATE=`/usr/bin/which date`
	ECHO=`/usr/bin/which echo`
	GREP=`/usr/bin/which grep`
	LOGGER=`/usr/bin/which logger`
	TAIL=`/usr/bin/which tail`

#CHECK FILE&PATH
	if [ ! -d $histDir ]
	then
		[ "`whoami`" != "root" ] && histDir=/home/$username/.hist
		mkdir -p $histDir
		chmod 777 $histDir
	fi

	if [ ! -d $histDir/${username} ]
	then
		mkdir -p $histDir/${username}
		touch $histDir/${username}/history.log
		chmod 600 $histDir/${username}/history.log
		chown -R ${username} $histDir/${username}
		chattr +a $histDir/${username}/history.log 2>/dev/null
	fi

	if [ ! -f $histDir/`$DATE +%Y.%m.%d`_history ]
	then
		touch $histDir/`$DATE +%Y.%m.%d`_history
		chmod 666 $histDir/`$DATE +%Y.%m.%d`_history
		chattr +a $histDir/`$DATE +%Y.%m.%d`_history 2>/dev/null
	fi


#EXPORTS
	export HISTSIZE=4096
	export HISTTIMEFORMAT="%Y.%m.%d-%H:%M:%S "
	export HISTFILE="$histDir/${username}/history.log"
	export ORIGNALUSER=`$ECHO $username`
	export USERIP=`$ECHO $userIP`
	export IPLIST=$(/sbin/ip ad sh |$GREP inet |$GREP -v inet6|awk -F' ' '{print $2}'|awk -F'/' '{print $1}' |$GREP -v '127.0.0.1'|tr -s "\n" "," |sed "s/|$//g")
	export PROMPT_COMMAND='{ ec=$?; history -w; read seq time cmd < <(history 1); [ -z "$time" ] || { '$ECHO' "$time|$IPLIST|${ORIGNALUSER},$(whoami)|$(pwd)|$('$CAT' $HISTFILE 2>/dev/null |'$TAIL' -n 1)|$ec|$USERIP" >> '$histDir'/`'$DATE' +%Y.%m.%d`_history; '$LOGGER' -t "audit.hist" -p 7 "$USERIP|${ORIGNALUSER}|$(whoami)|$(pwd)|$ec|$('$CAT' $HISTFILE 2>/dev/null |'$TAIL' -n 1)"; } }'
	readonly HISTSIZE HISTTIMEFORMAT HISTFILE ORIGNALUSER USERIP IPLIST PROMPT_COMMAND
