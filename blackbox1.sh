#!/bin/bash

podman run --replace \
  --name blackbox1 \
  -p 9115:9115 \
  --network bridge \
  -v $PWD/blackbox:/etc/blackbox_exporter:ro \
  -v $PWD/blackbox/blackbox1:/etc/blackbox_exporter/cert:ro \
  docker.io/prom/blackbox-exporter:master --config.file=/etc/blackbox_exporter/config.yml --web.config.file=/etc/blackbox_exporter/web_config.yaml