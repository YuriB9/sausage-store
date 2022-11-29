#!/bin/bash
set +e
cat > .env <<EOF
SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL}
SPRING_DATASOURCE_USERNAME=${SPRING_DATASOURCE_USERNAME}
SPRING_DATASOURCE_PASSWORD=${SPRING_DATASOURCE_PASSWORD}
SPRING_DATA_MONGODB_URI=${SPRING_DATA_MONGODB_URI}
EOF
docker network create -d bridge sausage_ci_network || true
docker pull gitlab.praktikum-services.ru:5050/std-009-060/sausage-store/sausage-backend:latest
docker container rm --force sausage-backend || true
set -e
docker container run --detach --name sausage-backend \
    --network=sausage_ci_network \
    --restart always \
    --pull always \
    --env-file .env \
    gitlab.praktikum-services.ru:5050/std-009-060/sausage-store/sausage-backend:latest