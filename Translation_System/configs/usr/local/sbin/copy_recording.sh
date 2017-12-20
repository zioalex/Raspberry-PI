#!/bin/bash -xv

SRC_DIR="/home/ubuntu/pre_recording/"
DEST_DIR="/mnt"
DEST_DEV="/dev/sda1"

RSYNC_OPT="-vz"

# Try to mount
mount $DEST_DEV $DEST_DIR 
MOUNT_EC=$?
if [ $MOUNT_EC -ne 0 ]
then
	logger "Error mounting $DEST_DEV"
else
	# Switch OFF Darkice
	systemctl stop darkice2.service
	rsync $RSYNC_OPT $SRC_DIR/* $DEST_DIR && logger "Copy Done" && rm -f $SRC_DIR/*
	# Umount 
	umount $DEST_DIR
fi

#and shutdown
shutdown -h now
