#!/bin/bash

podman run --replace \
  --name blackbox2 \
  -p 9116:9115 \
  --network bridge \
  -v $PWD/blackbox:/etc/blackbox_exporter:ro \
  -v $PWD/blackbox/blackbox2:/etc/blackbox_exporter/cert:ro \
  docker.io/prom/blackbox-exporter:master --config.file=/etc/blackbox_exporter/config.yml --web.config.file=/etc/blackbox_exporter/web_config.yaml