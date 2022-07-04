#!/usr/bin/env bash

# This file lives in /etc/local.d/oschooser.sh inside localhost.apkovl.tar.gz

set -x

#TEMP_DIR=$(grep /dev/sda2 /etc/mtab|cut -f2 -d' ')
#TEMP_DIR=/media/usb
#TEMP_DIR=/media/sda2
TEMP_DIR=/tmp/sda2
USB_DISK=/dev/sda
BTRFS_DIR=/tmp/usb3

createsubvolumename() {
  name="$1"
  typeset -l newvolname
  newvolname=${name// /_}
  newvolname=${newvolname//./__}
  echo $newvolname  
}

mkdir -p $TEMP_DIR
mount ${USB_DISK}2 $TEMP_DIR
options=()

if [ -f $TEMP_DIR/oslist.txt ];
then
  while read line
  do
    options+=("$line" "$line")
  done < $TEMP_DIR/oslist.txt
else
  echo "No OSes installed."
  exit 1
fi

CHOICE=$(whiptail --title "Choose OS" --menu " "  --nocancel --noitem   20 70 5 "${options[@]}" 3>&1 1>&2 2>&3)
volname=$(createsubvolumename "$CHOICE")
echo $volname

#umount /dev/sda2
#mount /dev/sda2 /media/sda2
find $TEMP_DIR ! -name "oslist.txt" -type f -exec rm -rf {} \;
find $TEMP_DIR -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;
#ls -l $TEMP_DIR
#sleep 30

mkdir -p $BTRFS_DIR
modprobe btrfs
mount -r ${USB_DISK}3 $BTRFS_DIR

if [ -d $BTRFS_DIR/@${volname}/boot/firmware ];
then
cp -r $BTRFS_DIR/@${volname}/boot/firmware/* $TEMP_DIR
else
cp -r $BTRFS_DIR/@${volname}/boot/* $TEMP_DIR
fi

echo -e "\ndtparam=sd_poll_once=on\n" >> $TEMP_DIR/config.txt

umount $BTRFS_DIR
umount $TEMP_DIR
sync
rm -rf $BTRFS_DIR
#rm -rf $TEMP_DIR
#sleep 60
/etc/local.d/rebootp.bin 2

