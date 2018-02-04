#!/bin/bash
set -e

# fetches debian dependencies
apt-get update
apt-get install -y curl openjdk-8.jdk wget net-tools \
        apt-utils apt-transport-https gnupg2 procps

curl -sL https://deb.nodesource.com/setup_9.x | bash -
apt-get install -y nodejs

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

# Kibana defaut configuration
npm install -g elasticdump
elasticdump \
  --output=http://localhost:9200/.kibana \
  --input=../ensure_kibana_configuration/dot.kibana.analyzer \
  --type=analyzer
elasticdump \
  --output=http://localhost:9200/.kibana \
  --input=../ensure_kibana_configuration/dot.kibana.mapping \
  --type=mapping
elasticdump \
  --output=http://localhost:9200/.kibana \
  --input=../ensure_kibana_configuration/dot.kibana.data \
  --type=data

# Logstash
apt-get install -y logstash
mkdir -p /etc/logstash/conf.d/
cat <<EOF > /etc/logstash/conf.d/logstash.conf
input {
    udp  {
        port => 9125
        type => "syslog"
    }
}

filter {
  
    grok {
      match => { "message" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: \[%{DATA:level}\] %{GREEDYDATA:syslog_message}" }
      add_field => [ "received_at", "%{@timestamp}" ]
      add_field => [ "received_from", "%{host}" ]
    }

    if [syslog_program] != "erlang" {
        drop { }
    }
  
}

output {
    elasticsearch { hosts => ["localhost:9200"] }
}
EOF
service logstash start
