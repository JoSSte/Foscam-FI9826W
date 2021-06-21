#!/bin/bash
## Script to repack e2jffs2.img filesystem using mtd kernel modules.
if [[ $# -lt 1 ]]
then
    echo "Usage: $0 e2jffs2.img"
    echo "(Full or relative paths can be used)"
    exit 1
fi
if [ '$(whoami)' != 'root' ]
then
    echo "$0 must be run as root!"
    exit 1
fi
if [[ ! -e $1 ]]
then
    echo "$1 does not exist"
    exit 1
fi
# cleanup if necessary
umount /tmp/e2jffs2 &>/dev/null
umount /tmp/mtdblock0 &>/dev/null
modprobe -r jffs2 &>/dev/null
modprobe -r block2mtd &>/dev/null
modprobe -r mtdblock &>/dev/null
sleep 0.25
losetup -d /dev/loop1 &>/dev/null
sleep 0.25
modprobe loop || exit 1
losetup /dev/loop1 "$1" || exit 1
modprobe block2mtd || exit 1
modprobe jffs2 || exit 1
if [[ ! -e /tmp/mtdblock0 ]]
then
    mknod /tmp/mtdblock0 b 31 0 || exit 1
fi
echo "/dev/loop1,128KiB" > /sys/module/block2mtd/parameters/block2mtd
if [[ ! -e /tmp/e2jffs2 ]]
then
    mkdir /tmp/e2jffs2
fi
mount -t jffs2 -o ro /tmp/mtdblock0 /tmp/e2jffs2 || exit 1
mkfs.jffs2 --root=/tmp/e2jffs2/ --output=/tmp/mtd_root.bin --eraseblock=128KiB --pad --no-cleanmarkers || exit 1
sumtool  --pad --eraseblock=128KiB --input=/tmp/mtd_root.bin --output=$(dirname $1)/mtd_root.sum.bin || exit 1
# cleanup if necessary
#umount /tmp/jffs2 &>/dev/null
#umount /tmp/mtdblock0 &>/dev/null
#modprobe -r jffs2 &>/dev/null
#modprobe -r block2mtd &>/dev/null
#modprobe -r mtdblock &>/dev/null
umount /tmp/e2jffs2
#umount /tmp/mtdblock0
modprobe -r jffs2
modprobe -r block2mtd
modprobe -r mtdblock
sleep 0.25
#losetup -d /dev/loop1 &>/dev/null
losetup -d /dev/loop1
sleep 0.25
rmdir /tmp/e2jffs2
rm /tmp/mtdblock0
rm /tmp/mtd_root.bin
mv $1 $1.orig && mv $(dirname $1)/mtd_root.sum.bin $1 || exit 1
echo "Successfully repacked $1"
exit 0