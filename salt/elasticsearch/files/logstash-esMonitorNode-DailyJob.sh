#!/bin/bash
CURL=`which curl`
NICE=`which nice`
SAVEDAYS="30"

echo $NICE -n 19 $CURL -XDELETE "http://localhost:9200/.marvel-`date --date="-$SAVEDAYS day" +%Y.%m.%d`/"
$NICE -n 19 $CURL -XDELETE "http://localhost:9200/.marvel-`date --date="-$SAVEDAYS day" +%Y.%m.%d`/"
echo
