#!/bin/sh -ex
## Install Apache Cassandra and dependencies.
## By Markus Klems (2013).
## Tested with Ubuntu 11.04,11.10, and 12.04.
## No warranties.

export DEBIAN_FRONTEND=noninteractive

## INSTALL DEPENDENCIES ##
ubuntuname=$(sudo cat /etc/lsb-release | echo `grep DISTRIB_CODENAME` | sed 's/DISTRIB_CODENAME=//')
sudo apt-get update -y
echo "deb http://debian.datastax.com/community stable main" | sudo -E tee -a /etc/apt/sources.list
echo "deb http://archive.canonical.com/ubuntu $ubuntuname partner" | sudo tee -a /etc/apt/sources.list.d/java.sources.list
sudo echo "sun-java6-bin shared/accepted-sun-dlj-v1-1 boolean true" | sudo debconf-set-selections
sudo apt-get update -y
sleep 1
# Remove openjdk.
sudo apt-get purge -y openjdk-6-jre-lib
sudo apt-get purge -y openjdk-7-jre openjdk-7-jre-lib
sudo apt-get autoremove -y
sudo apt-get update -y

# Install Oracle Java 1.6.
target_java_dir='/opt/java/64'
sudo mkdir -p $target_java_dir
url=http://download.oracle.com/otn-pub/java/jdk/6u35-b10/jdk-6u35-linux-x64.bin
tmpdir=`sudo mktemp -d`
# Silent download without Oracle licenses hassling us (hopefully).
sudo wget -c --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F" "$url" --output-document="$tmpdir/`basename $url`"
sudo chmod 777 $tmpdir
(cd $tmpdir; sudo sh `basename $url` -noregister)
sudo mkdir -p `dirname $target_java_dir`
(cd $tmpdir; sudo mv jdk1* $target_java_dir)
sudo rm -rf $tmpdir
# Setup java alternatives.
update-alternatives --install /usr/bin/java java "$target_java_dir/jdk1.6.0_35/bin/java" 17000
update-alternatives --set java "$target_java_dir/jdk1.6.0_35/bin/java"

# Try to set JAVA_HOME in a number of commonly used locations
export JAVA_HOME="$target_java_dir/jdk1.6.0_35"
if [ -f /etc/profile ]; then
  echo export JAVA_HOME=$JAVA_HOME >> /etc/profile
fi
if [ -f /etc/bashrc ]; then
  echo export JAVA_HOME=$JAVA_HOME >> /etc/bashrc
fi
if [ -f ~root/.bashrc ]; then
  echo export JAVA_HOME=$JAVA_HOME >> ~root/.bashrc
fi
if [ -f /etc/skel/.bashrc ]; then
  echo export JAVA_HOME=$JAVA_HOME >> /etc/skel/.bashrc
fi

sudo apt-get update -y
# Install packages. Fixme: should only install required packages here. Install optional packages with another script.
sudo apt-get -y install --fix-missing libjna-java htop emacs23-nox sysstat iftop binutils pssh pbzip2 zip unzip ruby openssl libopenssl-ruby curl maven2 ant liblzo2-dev ntp subversion python-pip tree unzip ruby
sudo apt-get -y install ca-certificates-java icedtea-6-jre-cacao java-common jsvc libavahi-client3 libavahi-common-data libavahi-common3 libcommons-daemon-java libcups2 libjna-java libjpeg62 liblcms1 libnspr4-0d libnss3-1d tzdata-java	
sudo apt-get update -y

## OS SETUP ##
# Avoid OS security limits to become a scalability bottleneck.
#sudo rm /etc/security/limits.conf
cat >limits.conf <<END_OF_FILE
* soft nofile 32768
* hard nofile 32768
root soft nofile 32768
root hard nofile 32768
* soft memlock unlimited
* hard memlock unlimited
root soft memlock unlimited
root hard memlock unlimited
* soft as unlimited
* hard as unlimited
root soft as unlimited
root hard as unlimited
END_OF_FILE
sudo mv limits.conf /etc/security/limits.conf
sudo chown root:root /etc/security/limits.conf
sudo chmod 755 /etc/security/limits.conf
# Disable swap
sudo swapoff --all

## INSTALL CASSANDRA ##
curl -L http://debian.datastax.com/debian/repo_key | sudo apt-key add -
curl -s http://opscenter.datastax.com/debian/repo_key | sudo apt-key add -
curl -s http://installer.datastax.com/downloads/ubuntuarchive.repo_key | sudo apt-key add -
sleep 2
sudo apt-get update -y
sleep 10
# Install DataStax Cassandra community edition
sudo apt-get install -y python-cql dsc-full
sudo service cassandra start
sudo service cassandra stop
# Install OpsCenter
sudo apt-get -y install opscenter-free
sudo service opscenterd start
sudo service opscenterd stop
