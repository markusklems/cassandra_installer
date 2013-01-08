#!/bin/sh -ex
## Setup of devices as RAID0 array.
## By Markus Klems (2012).
################################
### NO WARRANTIES WHATSOEVER ###
################################
export DEBIAN_FRONTEND=noninteractive

# Setup of devices.
umount /mnt
sleep 2
# Parameters:
MULTIDISK="/dev/md0"
sudo sh /home/ubuntu/cassandra_ami/configure_devices_as_RAID0.sh -m $MULTIDISK -d "/dev/xvdb /dev/xvdc"

# Remove and recreate cassandra directories.
C_LOG_DIR=/var/log/cassandra
C_LIB_DIR=/var/lib/cassandra
LV_LOG_DIR="/mnt$C_LOG_DIR"
LV_LIB_DIR="/mnt$C_LIB_DIR"
sudo rm -rf $C_LIB_DIR
sudo rm -rf $C_LOG_DIR
sudo mkdir -p $LV_LOG_DIR
sudo mkdir -p $LV_LIB_DIR
# Create links to cassandra log and lib dirs.
sudo ln -s $LV_LOG_DIR /var/log
sudo ln -s $LV_LIB_DIR /var/lib
# Make data, commitlog, and cache dirs.
sudo mkdir -p $LV_LIB_DIR/data
sudo mkdir -p $LV_LIB_DIR/commitlog
sudo mkdir -p $LV_LIB_DIR/saved_caches
# Allow access to everyone.
sudo chmod -R 777 $C_LIB_DIR
sudo chmod -R 777 $C_LOG_DIR
sudo chmod -R 777 $LV_LIB_DIR
sudo chmod -R 777 $LV_LOG_DIR