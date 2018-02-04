.PHONY: ops dev test default

default:
	@echo "EKL: Elastic Search & Kibana & Logstash"
	@echo "make [<ops>|<dev>]"
	@echo "make ops: runs EKL in a local dev environment"
	@echo "make test: runs the test erlang application"

ops:
#cd ops && sh ensure_default_kibana_configuration.sh &
	cd ops && docker-compose up --force-recreate --abort-on-container-exit 

test:
	cd ops/test_erlang && \
	docker-compose up --build --abort-on-container-exit 
