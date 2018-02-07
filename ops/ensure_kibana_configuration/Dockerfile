FROM node

WORKDIR /home/elasticdump
RUN npm install -g elasticdump

COPY ensure_default_kibana_configuration.sh .
COPY dot.kibana.analyzer .
COPY dot.kibana.mapping  .
COPY dot.kibana.data     .

CMD sh ensure_default_kibana_configuration.sh

