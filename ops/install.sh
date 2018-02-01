#!/bin/bash

# test it with:
# docker run --rm -p "9200:9200" -p "5601:5601" -p "9125:9125/udp" -it debian 

# fetches debian dependencies
apt-get update
apt-get install -y curl openjdk-8.jdk wget net-tools \
        apt-utils apt-transport-https gnupg2 procps

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch |  apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" |  tee -a /etc/apt/sources.list.d/elastic-6.x.list

# Elastic Search
apt-get install -y elasticsearch
service elasticsearch start

# Kivana
apt-get install -y kibana
cp kibana.yml /etc/kibana
service kibana start

# Logstash
apt-get install -y logstash
cp logstash.yml /etc/logstash/conf.d/
service logstash start
