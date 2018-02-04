.PHONY: ops dev test default

default:
	@echo "EKL: Elastic Search & Kibana & Logstash"
	@echo "make [<ops>|<dev>]"
	@echo "make ops: runs EKL in a local dev environment"
	@echo "make dev: opens erlang shell"
	@echo "make test: test install script"

ops:
	cd ops && \
	docker-compose build && \
	docker-compose up

ops_reset:
	cd ops && docker-compose down
dev:
	rebar3 shell

test:
	cd ops && sh test-install-script.sh
