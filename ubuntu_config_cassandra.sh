#!/bin/sh -ex
## Install Apache Cassandra and dependencies.
## By Markus Klems (2012).
## Tested with Ubuntu 11.04.
## No warranties.

mntpoint=${1:-/mnt}

# Create directories.
sudo mkdir /var/lib/cassandra
sudo mkdir /var/lib/cassandra/data
sudo mkdir /var/lib/cassandra/commitlog
sudo mkdir /var/lib/cassandra/saved_caches
sudo ln -s $mntpoint /var/lib/cassandra
sudo mkdir /var/log/cassandra
sudo mkdir /var/run/cassandra

# Replace the location of the pid file in the init script.
sudo sed -i -e "s|PIDFILE=/var/run/\$NAME.pid|PIDFILE=/var/run/cassandra/\$NAME.pid|" /etc/init.d/cassandra
# Remove the ulimit command from the init script.
# We configure the /etc/security/limits.d instead.
sudo sed -i -e "s|ulimit -l unlimited|#ulimit -n \"\$FD_LIMIT\"|" /etc/init.d/cassandra
sudo sed -i -e "s|ulimit -n \"\$FD_LIMIT\"|#ulimit -n \"\$FD_LIMIT\"|" /etc/init.d/cassandra

# Set access permission.
sudo chown -R cassandra:cassandra /etc/init.d/cassandra
sudo chown -R cassandra:cassandra /var/run/cassandra
sudo chown -R cassandra:cassandra /var/lib/cassandra
sudo chown -R cassandra:cassandra /var/log/cassandra
sudo chown -R cassandra:cassandra /etc/cassandra
sudo chown -R cassandra:cassandra /usr/share/cassandra
sudo chown -R cassandra:cassandra /usr/bin/cassandra-*
sudo chown -R cassandra:cassandra /usr/sbin/cassandra
sudo chown -R cassandra:cassandra /etc/default/cassandra
