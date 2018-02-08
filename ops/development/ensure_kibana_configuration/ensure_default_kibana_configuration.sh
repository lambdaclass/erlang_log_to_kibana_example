#!/bin/bash

es_host="elasticsearch:9200"

trials="20"
while [ $trials -gt 0 ]; do # wait for local kibana
  echo "$(date) waiting kibana ..."
  curl -XGET "$es_host/_cluster/state"
  if [ "$?" -eq 0 ]; then
    break
  fi
  trials=$((trials+1))
  sleep 5
done

# Create default index
curl -f -XPOST -H 'Content-Type: application/json' \
     -H 'kbn-xsrf: anything' \
     'http://kibana:5601/api/saved_objects/index-pattern/logstash-*' \
     '-d{"attributes":{"title":"logstash-*","timeFieldName":"@timestamp"}}'

# Imports dashboard
# exported with curl -XGET 'localhost:5601/api/kibana/dashboards/export?dashboard=<dashboard-id>' > dashboards.json
curl -XPOST kibana:5601/api/kibana/dashboards/import \
    -H 'kbn-xsrf:true' \
    -H 'Content-type:application/json' \
    -d @dashboards.json

echo "kibana configuration script ended"
