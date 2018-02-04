#!/bin/bash

rm dot.kibana.analyzer 
rm dot.kibana.mapping
rm dot.kibana.data
elasticdump \
  --input=http://localhost:9200/.kibana \
  --output=dot.kibana.analyzer \
  --type=analyzer
elasticdump \
  --input=http://localhost:9200/.kibana \
  --output=dot.kibana.mapping \
  --type=mapping
elasticdump \
  --input=http://localhost:9200/.kibana \
  --output=dot.kibana.data \
  --type=data
