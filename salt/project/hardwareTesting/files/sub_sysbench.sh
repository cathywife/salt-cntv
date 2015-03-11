#!/bin/bash

for thread in 16 32 64 128
do
	echo "####$thread####"
	sysbench --test=cpu --cpu-max-prime=50000 --max-requests=100000 --num-threads=${thread} run
done
