#!/bin/bash
ESHOST="localhost:9200"
CURL=`which curl`
NICE=`which nice`
DELDAY="`date --date="-10 day" +%Y.%m.%d`"
DELDAY2="`date --date="-3 day" +%Y.%m.%d`"
MOVETOP20DAY="`date --date="-2 day" +%Y.%m.%d`"
DONOTDEL="2015.09.01 2015.09.02 2015.09.03 2015.11.27 2015.11.28 2015.11.29"

if [ `echo "$DONOTDEL" |grep "$DELDAY" |wc -l` -eq 0 ]
then
	echo $NICE -n 19 $CURL -XDELETE "http://$ESHOST/logstash-$DELDAY/"
	$NICE -n 19 $CURL -XDELETE "http://$ESHOST/logstash-$DELDAY/"
fi

echo $NICE -n 19 $CURL -XDELETE "http://$ESHOST/packetbeat-$DELDAY2/"
$NICE -n 19 $CURL -XDELETE "http://$ESHOST/packetbeat-$DELDAY2/"

#echo $NICE -n 19 $CURL -XPOST "http://$ESHOST/logstash-`date --date="-1 day" +%Y.%m.%d`/_optimize"
#$NICE -n 19 $CURL -XPOST "http://$ESHOST/logstash-`date --date="-1 day" +%Y.%m.%d`/_optimize"

#echo $NICE -n 19 $CURL -XPOST "http://$ESHOST/logstash-`date --date="-$MOVETOP20DAYS day" +%Y.%m.%d`/_settings"
#$NICE -n 19 $CURL -XPOST "http://$ESHOST/logstash-`date --date="-$MOVETOP20DAYS day" +%Y.%m.%d`/_settings" -d '{
#"index.routing.allocation.include.box_type" : "P20"
#}'
