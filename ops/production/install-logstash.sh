#!/bin/bash
set -e

printf "Write Elastic Search host: "
read -r ELASTIC_SEARCH_HOST

apt-get update
apt-get install -y openjdk-8.jdk apt-utils apt-transport-https wget gnupg2

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" |  tee -a /etc/apt/sources.list.d/elastic-6.x.list
apt-get update

# Logstash
apt-get install -y logstash=1:6.1.3-1
mkdir -p /etc/logstash/conf.d/
cat <<EOF > /etc/logstash/conf.d/logstash.conf
input {
    udp  {
        codec => "json"
        port  => 9125
        type  => "erlang"
    }
}

output {
    elasticsearch { hosts => ["$ELASTIC_SEARCH_HOST:9200"] }
}
EOF
service logstash start
