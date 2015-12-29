OS="5 6 linux 7"
ARCH="x86_64"
workDir="/repo/cntvInternal"
#workDir="/repo/cntvInternal /repo/cntvCdh5"
cwd="/usr/local/cntv/yumSync"

for wd in `echo $workDir`
do
  for os in `echo $OS`
  do
    for arch in `echo $ARCH`
    do
      if [ -d $wd/RPMS/$os/$arch ]
      then
        createrepo -v -p -d -o $wd/RPMS/$os/$arch $wd/RPMS/$os/$arch
      fi
    done
  done
done