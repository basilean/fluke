#!/bin/bash

podman run --replace \
  --name nginx \
  -p 8080:80 \
  -p 8443:443 \
  --network bridge \
  -v $PWD/nginx:/etc/nginx:ro \
  -v $PWD/nginx/users:/etc/nginx/users:ro \
  -v $PWD/nginx/server:/etc/nginx/server:ro \
  -v $PWD/nginx/proxy:/etc/nginx/proxy:ro \
  -v $PWD/html:/usr/share/nginx/html:ro \
  docker.io/library/nginx:latest