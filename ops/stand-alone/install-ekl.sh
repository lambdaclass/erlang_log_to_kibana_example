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
apt-get install -y elasticsearch=6.1.3
service elasticsearch start

# Kibana
apt-get install -y kibana=6.1.3
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

# Kibana logtrail
service kibana stop
/usr/share/kibana/bin/kibana-plugin install \
  https://github.com/sivasamyk/logtrail/releases/download/v0.1.25/logtrail-6.1.3-0.1.25.zip
cat <<EOF > /usr/share/kibana/plugins/logtrail/logtrail.json
{
  "index_patterns" : [
    {
      "es": {
        "default_index": "logstash-*",
        "allow_url_parameter": false
      },
      "tail_interval_in_seconds": 10,
      "es_index_time_offset_in_seconds": 0,
      "display_timezone": "UTC",
      "display_timestamp_format": "YYYY MMM DD HH:mm:ss",
      "max_buckets": 500,
      "default_time_range_in_days" : 0,
      "max_hosts": 100,
      "max_events_to_keep_in_viewer": 5000,
      "fields" : {
        "mapping" : {
            "timestamp" : "@timestamp",
            "display_timestamp" : "@timestamp",
            "hostname" : "host",
            "program": "type",
            "message": "message"
        },
        "message_format": "{{{marker}}} | {{{message}}}"
      },
      "color_mapping" : {
        "field" : "log_level",
        "mapping" : {
          "ERROR": "#ff3232",
          "WARN": "#ff7f24",
          "DEBUG": "#ffb90f",
          "TRACE": "#a2cd5a"
         }
      }
    }
  ]
}
EOF
service kibana start

# Logstash
apt-get install -y logstash
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
    elasticsearch { hosts => ["localhost:9200"] }
}
EOF
service logstash start
