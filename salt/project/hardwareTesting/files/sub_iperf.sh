#!/bin/bash

#server：
/usr/local/bin/iperf -u -s &

#client：
/usr/local/bin/iperf -c localhost -u -i 2 -b 1000M -t 60
