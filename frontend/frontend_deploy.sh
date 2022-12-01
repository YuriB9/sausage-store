#!/bin/bash
set +e
docker network create -d bridge sausage_ci_network || true
docker pull $CI_REGISTRY_IMAGE/sausage-frontend:latest
docker container rm --force sausage-frontend || true
set -e
docker container run --detach --name sausage-frontend \
    --network=sausage_ci_network \
    --restart always \
    --pull always \
    --publish 80:80 \
    $CI_REGISTRY_IMAGE/sausage-frontend:latest