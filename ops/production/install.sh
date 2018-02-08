#!/bin/bash
set -e

echo "write kibana public network interface"
read ELK_PUBLIC_INTERFACE
echo "Write Elastic Search private network interface"
read ES_PRIVATE_INTERFACE
echo "Write user name"
read EKL_USER
echo "Write password"
read EKL_PASSWORD

# fetches debian dependencies
apt-get update
apt-get install -y curl openjdk-8.jdk wget net-tools \
        apt-utils apt-transport-https gnupg2 procps

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" |  tee -a /etc/apt/sources.list.d/elastic-6.x.list
apt-get update

# Elastic Search
apt-get install -y elasticsearch=6.1.3
mkdir -p /usr/share/elasticsearch/config/
cat <<EOF > /usr/share/elasticsearch/config/elasticsearch.yml
transport.host: localhost
transport.tcp.port: 9300
http.port: 9200
network.host:
EOF
ES_IP=$(ifconfig $ES_PRIVATE_INTERFACE | grep inet | cut -d: -f2 | \
               awk '{print $2}' | tr -d "\n")
sed -i -e "s/^network.host.*/network.host: $ES_IP /" \
    /usr/share/elasticsearch/config/elasticsearch.yml
service elasticsearch start

# Kibana
apt-get install -y kibana=6.1.3
cat << EOF > /etc/kibana/kibana.yml
server.host: "127.0.0.1"
EOF
service kibana start

# Kibana logtrail
service kibana stop
/usr/share/kibana/bin/kibana-plugin install \
  https://github.com/sivasamyk/logtrail/releases/download/v0.1.25/logtrail-6.1.3-0.1.25.zip
service kibana start

# nginx
apt-get install -y nginx apache2-utils
htpasswd -cb /etc/nginx/.htpasswd $EKL_USER $EKL_PASSWORD
cat <<EOF > /etc/nginx/sites-available/ekl
server {
listen
location / {
proxy_pass http://localhost:5601/;
auth_basic "Restricted";
auth_basic_user_file /etc/nginx/.htpasswd;
}
}
EOF
NGINX_IP=$(ifconfig $ELK_PUBLIC_INTERFACE | grep inet | cut -d: -f2 | \
               awk '{print $2}' | tr -d "\n")
sed -i -e "s/^listen.*/listen $NGINX_IP:5601; /" /etc/nginx/sites-available/ekl
ln -s /etc/nginx/sites-available/ekl /etc/nginx/sites-enabled/ekl
service nginx restart


## configurations...

# Kibana logstash indice
curl -f -XPOST -H 'Content-Type: application/json' \
     -H 'kbn-xsrf: anything' \
     'http://localhost:5601/api/saved_objects/index-pattern/logstash-*' \
     '-d{"attributes":{"title":"logstash-*","timeFieldName":"@timestamp"}}'

# Kibana dashboard
cat <<EOF > dashboards.json
{
  "version": "6.1.3",
  "objects": [
    {
      "id": "8c0b1af0-0c5d-11e8-8c55-19a00db19c22",
      "type": "visualization",
      "updated_at": "2018-02-07T23:49:43.465Z",
      "version": 1,
      "attributes": {
        "title": "Total Logs",
        "visState": "{\"title\":\"Total Logs\",\"type\":\"line\",\"params\":{\"type\":\"line\",\"grid\":{\"categoryLines\":false,\"style\":{\"color\":\"#eee\"}},\"categoryAxes\":[{\"id\":\"CategoryAxis-1\",\"type\":\"category\",\"position\":\"bottom\",\"show\":true,\"style\":{},\"scale\":{\"type\":\"linear\"},\"labels\":{\"show\":true,\"truncate\":100},\"title\":{}}],\"valueAxes\":[{\"id\":\"ValueAxis-1\",\"name\":\"LeftAxis-1\",\"type\":\"value\",\"position\":\"left\",\"show\":true,\"style\":{},\"scale\":{\"type\":\"linear\",\"mode\":\"normal\"},\"labels\":{\"show\":true,\"rotate\":0,\"filter\":false,\"truncate\":100},\"title\":{\"text\":\"Count\"}}],\"seriesParams\":[{\"show\":\"true\",\"type\":\"line\",\"mode\":\"normal\",\"data\":{\"label\":\"Count\",\"id\":\"1\"},\"valueAxis\":\"ValueAxis-1\",\"drawLinesBetweenPoints\":true,\"showCircles\":true}],\"addTooltip\":true,\"addLegend\":true,\"legendPosition\":\"right\",\"times\":[],\"addTimeMarker\":false},\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"schema\":\"metric\",\"params\":{}},{\"id\":\"2\",\"enabled\":true,\"type\":\"date_histogram\",\"schema\":\"segment\",\"params\":{\"field\":\"@timestamp\",\"interval\":\"auto\",\"customInterval\":\"2h\",\"min_doc_count\":1,\"extended_bounds\":{}}}]}",
        "uiStateJSON": "{}",
        "description": "",
        "version": 1,
        "kibanaSavedObjectMeta": {
          "searchSourceJSON": "{\"index\":\"logstash-*\",\"filter\":[],\"query\":{\"query\":\"\",\"language\":\"lucene\"}}"
        }
      }
    },
    {
      "id": "34b96fe0-0c5d-11e8-8c55-19a00db19c22",
      "type": "visualization",
      "updated_at": "2018-02-07T23:49:43.400Z",
      "version": 1,
      "attributes": {
        "title": "Log level proportion",
        "visState": "{\"title\":\"Log level proportion\",\"type\":\"pie\",\"params\":{\"type\":\"pie\",\"addTooltip\":true,\"addLegend\":true,\"legendPosition\":\"right\",\"isDonut\":true,\"labels\":{\"show\":false,\"values\":true,\"last_level\":true,\"truncate\":100}},\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"schema\":\"metric\",\"params\":{}},{\"id\":\"2\",\"enabled\":true,\"type\":\"terms\",\"schema\":\"segment\",\"params\":{\"field\":\"fields.level.keyword\",\"size\":5,\"order\":\"desc\",\"orderBy\":\"1\"}}]}",
        "uiStateJSON": "{}",
        "description": "",
        "version": 1,
        "kibanaSavedObjectMeta": {
          "searchSourceJSON": "{\"index\":\"logstash-*\",\"filter\":[],\"query\":{\"query\":\"\",\"language\":\"lucene\"}}"
        }
      }
    },
    {
      "id": "7ae85b20-0c5d-11e8-8c55-19a00db19c22",
      "type": "visualization",
      "updated_at": "2018-02-07T23:49:43.460Z",
      "version": 1,
      "attributes": {
        "title": "Log level",
        "visState": "{\"title\":\"Log level\",\"type\":\"area\",\"params\":{\"type\":\"area\",\"grid\":{\"categoryLines\":false,\"style\":{\"color\":\"#eee\"}},\"categoryAxes\":[{\"id\":\"CategoryAxis-1\",\"type\":\"category\",\"position\":\"bottom\",\"show\":true,\"style\":{},\"scale\":{\"type\":\"linear\"},\"labels\":{\"show\":true,\"truncate\":100},\"title\":{}}],\"valueAxes\":[{\"id\":\"ValueAxis-1\",\"name\":\"LeftAxis-1\",\"type\":\"value\",\"position\":\"left\",\"show\":true,\"style\":{},\"scale\":{\"type\":\"linear\",\"mode\":\"normal\"},\"labels\":{\"show\":true,\"rotate\":0,\"filter\":false,\"truncate\":100},\"title\":{\"text\":\"Count\"}}],\"seriesParams\":[{\"show\":\"true\",\"type\":\"area\",\"mode\":\"stacked\",\"data\":{\"label\":\"Count\",\"id\":\"1\"},\"drawLinesBetweenPoints\":true,\"showCircles\":true,\"interpolate\":\"linear\",\"valueAxis\":\"ValueAxis-1\"}],\"addTooltip\":true,\"addLegend\":true,\"legendPosition\":\"right\",\"times\":[],\"addTimeMarker\":false},\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"schema\":\"metric\",\"params\":{}},{\"id\":\"2\",\"enabled\":true,\"type\":\"date_histogram\",\"schema\":\"segment\",\"params\":{\"field\":\"@timestamp\",\"interval\":\"auto\",\"customInterval\":\"2h\",\"min_doc_count\":1,\"extended_bounds\":{}}},{\"id\":\"3\",\"enabled\":true,\"type\":\"terms\",\"schema\":\"group\",\"params\":{\"field\":\"fields.level.keyword\",\"size\":5,\"order\":\"desc\",\"orderBy\":\"1\"}}]}",
        "uiStateJSON": "{}",
        "description": "",
        "version": 1,
        "kibanaSavedObjectMeta": {
          "searchSourceJSON": "{\"index\":\"logstash-*\",\"filter\":[],\"query\":{\"query\":\"\",\"language\":\"lucene\"}}"
        }
      }
    },
    {
      "id": "4ec1b690-0c5d-11e8-8c55-19a00db19c22",
      "type": "visualization",
      "updated_at": "2018-02-07T23:49:43.422Z",
      "version": 1,
      "attributes": {
        "title": "Environment Proportion",
        "visState": "{\"title\":\"Environment Proportion\",\"type\":\"pie\",\"params\":{\"type\":\"pie\",\"addTooltip\":true,\"addLegend\":true,\"legendPosition\":\"right\",\"isDonut\":true,\"labels\":{\"show\":false,\"values\":true,\"last_level\":true,\"truncate\":100}},\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"schema\":\"metric\",\"params\":{}},{\"id\":\"2\",\"enabled\":true,\"type\":\"terms\",\"schema\":\"segment\",\"params\":{\"field\":\"env.keyword\",\"size\":5,\"order\":\"desc\",\"orderBy\":\"1\"}}]}",
        "uiStateJSON": "{}",
        "description": "",
        "version": 1,
        "kibanaSavedObjectMeta": {
          "searchSourceJSON": "{\"index\":\"logstash-*\",\"filter\":[],\"query\":{\"query\":\"\",\"language\":\"lucene\"}}"
        }
      }
    },
    {
      "id": "logstash-*",
      "type": "index-pattern",
      "updated_at": "2018-02-07T23:33:46.389Z",
      "version": 1,
      "attributes": {
        "title": "logstash-*",
        "timeFieldName": "@timestamp"
      }
    },
    {
      "id": "9934db30-0c5d-11e8-8c55-19a00db19c22",
      "type": "dashboard",
      "updated_at": "2018-02-07T23:49:43.395Z",
      "version": 1,
      "attributes": {
        "title": "Default Dashboard",
        "hits": 0,
        "description": "",
        "panelsJSON": "[{\"panelIndex\":\"1\",\"gridData\":{\"x\":0,\"y\":0,\"w\":6,\"h\":3,\"i\":\"1\"},\"version\":\"6.1.3\",\"type\":\"visualization\",\"id\":\"8c0b1af0-0c5d-11e8-8c55-19a00db19c22\"},{\"panelIndex\":\"2\",\"gridData\":{\"x\":6,\"y\":0,\"w\":6,\"h\":3,\"i\":\"2\"},\"version\":\"6.1.3\",\"type\":\"visualization\",\"id\":\"34b96fe0-0c5d-11e8-8c55-19a00db19c22\"},{\"panelIndex\":\"3\",\"gridData\":{\"x\":0,\"y\":3,\"w\":6,\"h\":3,\"i\":\"3\"},\"version\":\"6.1.3\",\"type\":\"visualization\",\"id\":\"7ae85b20-0c5d-11e8-8c55-19a00db19c22\"},{\"gridData\":{\"w\":6,\"h\":3,\"x\":6,\"y\":3,\"i\":\"4\"},\"version\":\"6.1.3\",\"panelIndex\":\"4\",\"type\":\"visualization\",\"id\":\"4ec1b690-0c5d-11e8-8c55-19a00db19c22\"}]",
        "optionsJSON": "{\"darkTheme\":false,\"useMargins\":true,\"hidePanelTitles\":false}",
        "uiStateJSON": "{}",
        "version": 1,
        "timeRestore": false,
        "kibanaSavedObjectMeta": {
          "searchSourceJSON": "{\"query\":{\"query\":\"\",\"language\":\"lucene\"},\"filter\":[],\"highlightAll\":true,\"version\":true}"
        }
      }
    }
  ]
}
EOF
curl -XPOST localhost:5601/api/kibana/dashboards/import \
    -H 'kbn-xsrf:true' \
    -H 'Content-type:application/json' \
    -d @dashboards.json
rm dashboards.json

# Kibana logtrail conf
service kibana stop
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
