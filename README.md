# erlang_log_to_kibana
Demonstration of how to setup Elastic Search, Kibana and, Logstash with Erlang lager.

## stand-alone script
Check `ops/install.sh`, it will install everything and start all services.

## Usage

- `make ops` starts the three services with docker compose.
- `make dev` starts the erlang console, then use `lager:start` and `lager:log`.

You can see the logged data at `http://localhost:5601/app/kibana#/dev_tools/`.
