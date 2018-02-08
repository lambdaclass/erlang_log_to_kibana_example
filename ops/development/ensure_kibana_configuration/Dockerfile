FROM node

WORKDIR /home/elasticdump
RUN npm install -g elasticdump

COPY ensure_default_kibana_configuration.sh .
COPY dashboards.json .

CMD sh ensure_default_kibana_configuration.sh

