#!/bin/bash

resultDir="result/`date "+%Y-%m-%d_%H%M%S"`"
tests="fio iperf mbw sysbench"

for test in $tests
do
	mkdir -p $resultDir/$test
	echo "`date "+%Y-%m-%d_%H:%M:%S"`	${test} start" |tee -a $resultDir/$test/raw.log
	/usr/bin/time -ao $resultDir/$test/raw.log ./sub_${test}.sh >> $resultDir/$test/raw.log 2>&1
	echo "`date "+%Y-%m-%d_%H:%M:%S"`	${test} finished" |tee -a $resultDir/$test/raw.log
done
