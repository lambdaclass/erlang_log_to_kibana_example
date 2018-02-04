# erlang_log_to_kibana
Demonstration of how to setup Elastic Search, Kibana and, Logstash with Erlang lager.

## stand-alone script
- `ops/stand-alone/install-ekl.sh`: install Elastic Search, Kibana and Logstash.

## Usage

- `make ops` starts every service and initializes kibana.
- `make test` starts an erlang application that generates random logs.

You can see the logged data at `http://localhost:5601/` and click in 'Dashboard'. 
If the status of kibana is RED saying something about outdated indexes is
because the default configuration is still being uploaded, wait 5 to 20 seconds 
and reload the page.
