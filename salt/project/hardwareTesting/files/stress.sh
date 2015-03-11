echo "[random_rw]
rw=randrw
size=1024M
numjobs=32
directory=/data/disktest" > src/stress.fio
mkdir -p /data/disktest

while true
do
        killall -0 fio || /usr/local/bin/fio src/stress.fio > /dev/null &
        killall -0 mbw || /usr/local/bin/mbw `free -m |grep "^Mem" |awk '{print $2-2048}'` > /dev/null &
        killall -0 sysbench || sysbench --test=cpu --cpu-max-prime=5000000 --max-requests=10000000 --num-threads=`cat /proc/cpuinfo |grep "^processor" |wc -l` run > /dev/null &
        sleep 1
done