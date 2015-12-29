#!/bin/bash

baseDir=`pwd`
dockerCmd=`which docker`
dockerServer="10.70.58.183:5000"

function cleanup()
{
	#删除未提交到registry的容器
	$dockerCmd ps |awk '{print $1"\t"$2}' |grep -v "$dockerServer\|ID" |while read conID imgId
	do
		$dockerCmd stop $conID |sed "s/^/stop:/g"
		$dockerCmd rm $conID |sed "s/^/del:/g"
	done
	
	#删除无效镜像
	$dockerCmd images |grep "<none>" |while read n1 n2 id other
	do
		$dockerCmd rmi $id >/dev/null 2>&1 && echo "del:$id"
	done
}

function prepare()
{
	cleanup
	#关闭删除已经在运行的同名容器、删除已存在的同名镜像
	$dockerCmd ps -a |grep $dockerImage |while read id other
	do
		$dockerCmd stop $id |sed "s/^/stop:/g"
		$dockerCmd rm $id |sed "s/^/del:/g"
		$dockerCmd rmi $dockerServer/$dockerImage >/dev/null 2>&1 && echo "del:$dockerServer/$dockerImage"
	done
}

if [ $# -ge 1 ]
then
	echo $@ |sed "s/\/\( \|$\)/\n/g" |while read dockerImage
	do
		if [ "$dockerImage" != "" ]
		then
			dockerArgv=`cat $baseDir/$dockerImage/run.conf |grep "^dockerArgv" |awk -F= '{print $2}' |sed "s/\"//g"`
			prepare
			$dockerCmd run $dockerArgv $dockerServer/$dockerImage
			#cip=`$dockerCmd inspect $cid |grep "IPAddress" |awk -F: '{print $2}' |sed "s/\(\"\|,\| \)//g"`
			#echo "containerIP: $cip containerID: $cid"
			cleanup
		fi
	done
else
	echo "usage $0 name1 name2 ..."
	exit 1
fi