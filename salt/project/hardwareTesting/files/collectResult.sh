#!/bin/bash

if [ $# -eq 0 ]
then
	path="/root/testSuite/result/`ls /root/testSuite/result |tail -n1`"
else
	path=$1
fi

echo "`basename $path` report:"

echo "fio:"
echo "subject,read(MB/s),read IOPS,write(MB/s),write IOPS,%CPU"
> $path/fio/result.log
ls -tr $path/fio/log |grep ".log$" |while read file
do
	cat $path/fio/log/$file |grep "^[0-9];fio-" |sed "s/%//g" |awk -F\; '{printf "%s,%.2f,%d,%.2f,%d,%.2f%\n",$3,$7/1024,$8,$48/1024,$49,$89}' |tee -a $path/fio/result.log
done

echo "mbw:"
cat $path/mbw/raw.log |grep "^AVG" |tee $path/mbw/result.log

echo "ipref:"
cat $path/iperf/raw.log |grep -P "\d+\.\d+ ms|\[ ID\].*Jitter|user \d+\.\d+system"  |tee $path/ipref/result.log

echo "sysbench:"
cat $path/sysbench/raw.log |grep "^####\|execution time" |tee $path/sysbench/result.log
