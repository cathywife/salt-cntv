#!/bin/bash

bs="4k 16k 64k 256k 1m 4m"
thread="1 4 16 64 128"
rw="read write"
totalsize="16384"

echo "#bs thread rw size"
for r in `echo $rw`
do
	for b in `echo $bs`
	do
		if [ `echo $b |grep "k$"` ]
		then
			r1="rand$r"
		else
			r1="$r"
		fi
		for t in `echo $thread`
		do
		
			echo "$b $t $r1 $[$totalsize/$t]m"
		done
	done
done