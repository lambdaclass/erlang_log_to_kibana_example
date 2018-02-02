.PHONY: ops dev test default

default:
	@echo "EKL: Elastic Search & Kibana & Logstash"
	@echo "make [<ops>|<dev>]"
	@echo "make ops: runs EKL in a local dev environment"
	@echo "make dev: opens erlang shell"
	@echo "make test: test install script"

ops:
	cd ops && sh ensure_default_kibana_configuration.sh &
	cd ops && docker-compose up --force-recreate --abort-on-container-exit 

dev:
	rebar3 shell --apps log

test:
	cd ops && sh test-install-script.sh
