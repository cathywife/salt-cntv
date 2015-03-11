#!/bin/bash

if [ $# -eq 1 ]
then
	resultDir=${1}/fio/log
else
	resultDir="result/`date "+%Y-%m-%d_%H%M%S"`/fio/log"
fi
workDir="/root/testSuite"

mkdir -p /data/disktest
mkdir -p $resultDir

cat $workDir/src/fioProfile.list |grep -v "^#\|^$" |while read bs thread rw size
do
	cat $workDir/src/fioGlobal.fio > $workDir/src/fio-${bs}-${thread}-${rw}.fio
	echo -e "[${bs}-${thread}-${rw}]\nstonewall\nbs=$bs\nsize=$size\nrw=$rw\nnumjobs=$thread\n" >> $workDir/src/fio-${bs}-${thread}-${rw}.fio
	echo "testing fio: ${bs}-${thread}-${rw}"
	/usr/local/bin/fio --append-terse --output $resultDir/${bs}-${thread}-${rw}.log $workDir/src/fio-${bs}-${thread}-${rw}.fio
	rm -f /data/disktest/*.0
done
