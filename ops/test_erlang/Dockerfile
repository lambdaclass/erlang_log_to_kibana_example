FROM erlang

RUN apt-get update && \
    apt-get install -y rsyslog netcat

WORKDIR /home/erlang
RUN mkdir -p /etc/rsyslog.d/
COPY ops/test_erlang/rsyslog.conf /etc/rsyslog.conf

ADD . .
RUN rebar3 as prod release
CMD rsyslogd -n -f /etc/rsyslog.conf & _build/prod/rel/prod/bin/prod

