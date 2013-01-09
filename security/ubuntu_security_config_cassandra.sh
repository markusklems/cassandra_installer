#!/bin/sh -ex
## Setup of Cassandra security features.
## By Markus Klems (2013).
## No warranties.

export DEBIAN_FRONTEND=noninteractive

CASSANDRA_HOME=/usr/local/apache-cassandra-1.2.0

# Certificate and jks commands for reference:
#sudo keytool -genkeypair -alias certificatekey -keyalg RSA -validity 7 -keystore keystore.jks
#sudo keytool -importkeystore -srckeystore keystore.jks -destkeystore keystore-jks.p12 -deststoretype PKCS12
#sudo keytool -export -alias certificatekey -keystore keystore.jks -rfc -file cert.cer
#sudo keytool -import -alias certificatekey -file cert.cer -keystore truststore.jks

# create keystore from p12 package
echo "cassandra
cassandra
cassandra
yes" | sudo keytool -v -importkeystore -srckeystore keystore-jks.p12 -srcstoretype PKCS12 -destkeystore "$CASSANDRA_HOME/conf/keystore.jks" -deststoretype JKS
	
# create truststore
echo "cassandra
cassandra
yes" | sudo keytool -import -alias certificatekey -file cert.cer -keystore "$CASSANDRA_HOME/conf/truststore.jks"
	
# Replace the cassandra conf files
cp cassandra-env.sh "$CASSANDRA_HOME/conf/cassandra-env.sh"
cp cassandra.yaml "$CASSANDRA_HOME/conf/cassandra.yaml"

# Download java security libs
sudo wget -c --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F" http://download.oracle.com/otn-pub/java/jce_policy/6/jce_policy-6.zip
sudo unzip jce_policy-6.zip
sudo cp -f jce/* /opt/java/64/jdk1.6.0_35/jre/lib/security/.
sudo rm -Rf jce*