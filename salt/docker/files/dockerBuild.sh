#!/bin/bash

dockerCmd=`which docker`
dockerServer="10.70.58.183:5000"

function buildImage()
{
	dockerImage=$1
	echo "building: $dockerServer/$dockerImage"
	$dockerCmd build -t $dockerServer/$dockerImage /data/docker-files/$dockerImage
	$dockerCmd push $dockerServer/$dockerImage
}

function cleanup()
{
	$dockerCmd stop `$dockerCmd ps -a |grep "$dockerImage:latest" |awk '{print $1}'` 2>/dev/null
	$dockerCmd rm `$dockerCmd ps -a -q` 2>/dev/null
	$dockerCmd images |grep "<none>" |while read n1 n2 id other
	do
		$dockerCmd rmi $id
	done
}

if [ $# -ge 1 ]
then
	echo $@ |sed "s/\/\( \|$\)/\n/g" |while read dockerImage
	do
		if [ "$dockerImage" != "" ]
		then
			cleanup $dockerImage
			buildImage $dockerImage
			cleanup $dockerImage
		fi
	done
else
	echo "usage $0 name1 name2 ..."
	exit 1
fi