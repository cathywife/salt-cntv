OS="5 6"
ARCH="i386 x86_64"
workDir="/repo/cntvInternal"
cwd="/usr/local/cntv/yumSync"

for os in `echo $OS`
do
  for arch in `echo $ARCH`
  do
    createrepo -v -p -d -o $workDir/RPMS/$os/$arch $workDir/RPMS/$os/$arch
  done
done
