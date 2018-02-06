.PHONY: ops dev test default

default:
	@echo "EKL: Elastic Search & Kibana & Logstash"
	@echo "make [<ops>|<dev>]"
	@echo "make ops: runs EKL in a local dev environment"
	@echo "make test: runs the test erlang application"

ops:
	cd ops/ensure_kibana_configuration && \
	 docker-compose up --build --force-recreate -d
	cd ops/ekl && docker-compose up --force-recreate --abort-on-container-exit 

test:
	rebar3 shell
