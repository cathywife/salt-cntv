#!/bin/bash

#SET VAR
	username=`who -u am i 2>/dev/null| awk '{print $1}'`
	userIP=`who -u am i 2>/dev/null| awk '{print $NF}'|sed -e 's/[()]//g'`
	DT=`/bin/date +%Y%m%d_%H%M%S`
	histDir=/var/log/.hist
	LOGGER=`/usr/bin/which logger`
	DATE=`/usr/bin/which date`
	ECHO=`/usr/bin/which echo`
	GREP=`/usr/bin/which grep`

#CHECK FILE&PATH
	if [ ! -d $histDir ]
	then
		[ "`whoami`" == "root" ] || histDir=/home/$username/.hist
		mkdir -p $histDir
		chmod 777 $histDir
	fi

	if [ ! -d $histDir/${username} ]
	then
		mkdir -p $histDir/${username}
		chmod 600 $histDir/${LOGNAME}/*.hist* 2>/dev/null
	fi

	if [ ! -f $histDir/`$DATE +%Y.%m.%d`_history ]
	then
		touch $histDir/`$DATE +%Y.%m.%d`_history
		chmod 666 $histDir/`$DATE +%Y.%m.%d`_history
		chattr +a $histDir/`$DATE +%Y.%m.%d`_history 2>/dev/null
	fi


#EXPORTS
	export HISTTIMEFORMAT="%Y.%m.%d-%H:%M:%S "
	export HISTSIZE=4096
	export HISTFILE="$histDir/${username}/${userIP}.hist.$DT"
	export ORIGNALUSER=`$ECHO $username`
	export USERIP=`$ECHO $userIP`
	export IPLIST=$(/sbin/ip ad sh |$GREP inet |$GREP -v inet6|awk -F' ' '{print $2}'|awk -F'/' '{print $1}' |$GREP -v '127.0.0.1'|tr -s "\n" "," |sed "s/|$//g")
	export PROMPT_COMMAND='{ ec=$?; read seq time cmd < <(history 1); [ -z "$time" ] || { '$ECHO' "$time|$IPLIST|${ORIGNALUSER},$(whoami)|$(pwd)|$cmd|$ec|$USERIP" >> '$histDir'/`'$DATE' +%Y.%m.%d`_history; '$LOGGER' -t "audit.hist" -p 7 "$USERIP|${ORIGNALUSER}|$(whoami)|$(pwd)|$ec|$cmd"; } }'
	readonly HISTTIMEFORMAT HISTSIZE HISTFILE ORIGNALUSER USERIP IPLIST PROMPT_COMMAND
