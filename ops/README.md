OPS
===

Description of each folder

## Development
[ELK] abbreviation for Elastic Search, Kibana and Logstash. The
`development` folder  contains a [docker-compose] project to create
an [EKL] local test environment. The files are following:

- `docker-compose.yml` definitions of all the three containers of the
  [EKL] stack.
- `kibana.yml`, `logstash.conf`, `logtrail.json` and `elasticsearch.yml`,
  are the configuration files of each component.
- `kibana-dockerfile`: Modified Kibana docker image which installs
  [Logtrail].
- `ensure_kibana_default_configuration.sh`: creates the logstash
  index for Kibana consumption, and set a default dashboard with
  sample visualizations.

## Production
[Auto contained script](production/).


[ELK]: https://www.elastic.co/elk-stack
[docker-compose]: https://docs.docker.com/compose/install/
[Logtrail]: https://github.com/sivasamyk/logtrail
