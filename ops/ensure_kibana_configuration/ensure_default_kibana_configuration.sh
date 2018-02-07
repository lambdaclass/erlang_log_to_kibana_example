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

elasticdump \
  --output=http://$es_host/.kibana \
  --input=dot.kibana.analyzer \
  --type=analyzer
elasticdump \
  --output=http://$es_host/.kibana \
  --input=dot.kibana.mapping \
  --type=mapping
elasticdump \
  --output=http://$es_host/.kibana \
  --input=dot.kibana.data \
  --type=data

echo "kibana configuration script ended"
