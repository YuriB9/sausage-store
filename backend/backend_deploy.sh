#!/bin/bash
set +e
cat > .env <<EOF
SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL}
SPRING_DATASOURCE_USERNAME=${SPRING_DATASOURCE_USERNAME}
SPRING_DATASOURCE_PASSWORD=${SPRING_DATASOURCE_PASSWORD}
SPRING_DATA_MONGODB_URI=${SPRING_DATA_MONGODB_URI}

EOF
docker network create -d bridge sausage_ci_network || true
docker pull ${CI_REGISTRY_IMAGE}/sausage-backend:latest
docker container rm --force sausage-backend || true
set -e
docker container run --detach --name sausage-backend \
    --network=sausage_ci_network \
    --restart always \
    --pull always \
    --env-file .env \
    ${CI_REGISTRY_IMAGE}/sausage-backend:latest