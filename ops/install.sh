#!/bin/bash
set -e

# fetches debian dependencies
apt-get update
apt-get install -y curl openjdk-8.jdk wget net-tools \
        apt-utils apt-transport-https gnupg2 procps

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" |  tee -a /etc/apt/sources.list.d/elastic-6.x.list
apt-get update

# Elastic Search
apt-get install -y elasticsearch
service elasticsearch start

# Kibana
apt-get install -y kibana
cat << EOF > /etc/kibana/kibana.yml
server.host: "0.0.0.0"
EOF
service kibana start

# Logstash
apt-get install -y logstash
mkdir -p /etc/logstash/conf.d/
cat <<EOF > /etc/logstash/conf.d/logstash.conf
    input {
    udp  {
        codec => "json"
        port => 9125
        type => "erlang"
    }
}
output {
    elasticsearch { hosts => ["localhost:9200"] }
    stdout { codec => rubydebug }
}
EOF
service logstash start
