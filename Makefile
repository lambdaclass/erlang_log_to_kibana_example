.PHONY: ops dev test default

default:
	@echo "EKL: Elastic Search & Kibana & Logstash"
	@echo "make [<ops>|<test-prod><test-debug>]"
	@echo "make ops: runs EKL in a local dev environment"
	@echo "make test-[debug|prod]: runs the test erlang application with different ENV variable set"

ops:
	cd ops/development/ && \
	 sh ensure_default_kibana_configuration.sh &
	cd ops/development && \
	 docker-compose up --build --force-recreate --abort-on-container-exit

test-prod:
	export ENV="prod" && rebar3 shell

test-debug:
	export ENV="debug" && rebar3 shell
