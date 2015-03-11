count=`df -m /data/disktest/ |grep "^/" |awk '{print int($4/4096)}'`
echo "[global]
ioengine=libaio
thread=1
buffered=0
direct=1
directory=/data/disktest
group_reporting
iodepth=64" > fullDisk.fio
for((i=1;i<=$count;i++))
do
echo "[fullDisk${i}]
stonewall
bs=1m
size=4g
rw=write
numjobs=1" >> fullDisk.fio
done
/usr/local/bin/fio fullDisk.fio
