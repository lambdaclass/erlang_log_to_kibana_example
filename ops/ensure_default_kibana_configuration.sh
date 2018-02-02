#!/bin/bash

while true; do # wait for local kibana
  echo "$(date) waiting kibana ..."
  curl -XGET 'localhost:9200/_cluster/state'
  if [ "$?" -eq 0 ]; then 
    break
  fi
  sleep 5
done

elasticdump \
  --output=http://localhost:9200/.kibana \
  --input=dot.kibana.analyzer \
  --type=analyzer
elasticdump \
  --output=http://localhost:9200/.kibana \
  --input=dot.kibana.mapping \
  --type=mapping
elasticdump \
  --output=http://localhost:9200/.kibana \
  --input=dot.kibana.data \
  --type=data

echo "kibana configuration script ended"
