OPS
===

Description of each folder

## ekl
EKL abbreviation for Elastic Search, Kibana and Logstash. It contains
sample debug configuration for testing EKL locally. It uses
`docker-compose` to run.

## ensure_kibana_configuration
Currently the automatic setup of kibana indices and other configuration
is done importing and exporting the `.kibana` database directly.
This folder contains a container that setups that configuration
automatically. Also contains two script for doing it manually.

- `save_current_kibana_conf.sh`: imports the database of kibana to three
  files: `dot.kibana.data`, `dot.kibana.mapping`, `dot.kibana.analyzer`.
- `ensure_default_kibana_configuration`: Restore the kibana database using
  the files listed above.

## stand_alone
[Auto contained script](stand_alone/)
