#!/bin/sh -ex
## Setup of Cassandra security features.
## By Markus Klems (2013).
## No warranties.

export DEBIAN_FRONTEND=noninteractive

CASSANDRA_HOME=/usr/local/apache-cassandra-1.2.0-rc2

# Certificate and jks commands for reference:
#sudo keytool -genkeypair -alias certificatekey -keyalg RSA -validity 7 -keystore keystore.jks
#sudo keytool -importkeystore -srckeystore keystore.jks -destkeystore keystore-jks.p12 -deststoretype PKCS12
#sudo keytool -export -alias certificatekey -keystore keystore.jks -rfc -file cert.cer
#sudo keytool -import -alias certificatekey -file cert.cer -keystore truststore.jks

# create keystore from p12 package
sudo keytool -v -importkeystore -srckeystore keystore-jks.p12 -srcstoretype PKCS12 -destkeystore "$CASSANDRA_HOME/conf/keystore.jks" -deststoretype JKS
	
# create truststore
echo "cassandra
cassandra
yes" | sudo keytool -import -alias certificatekey -file cert.cer -keystore "$CASSANDRA_HOME/conf/truststore.jks"
	
# Replace the cassandra conf files
cp cassandra-env.sh "$CASSANDRA_HOME/conf/cassandra-env.sh"
cp cassandra.yaml "$CASSANDRA_HOME/conf/cassandra.yaml"