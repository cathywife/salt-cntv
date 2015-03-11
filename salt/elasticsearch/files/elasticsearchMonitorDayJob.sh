#!/bin/bash
CURL=`which curl`
NICE=`which nice`
SAVEDAYS="7"

echo $NICE -n 19 $CURL -XDELETE "http://localhost:9200/.marvel-`date --date="-$SAVEDAYS day" +%Y.%m.%d`/"
$NICE -n 19 $CURL -XDELETE "http://localhost:9200/.marvel-`date --date="-$SAVEDAYS day" +%Y.%m.%d`/"
echo

for i in `seq 1 30`
do
	echo -n "."
	sleep 1
done
echo

echo $NICE -n 19 $CURL -XPOST "http://localhost:9200/.marvel-`date --date="-1 day" +%Y.%m.%d`/_optimize"
$NICE -n 19 $CURL -XPOST "http://localhost:9200/.marvel-`date --date="-1 day" +%Y.%m.%d`/_optimize"
echo

