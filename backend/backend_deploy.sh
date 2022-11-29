#!/bin/bash
set +e
cat > .env <<EOF
SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL}
SPRING_DATASOURCE_USERNAME=${SPRING_DATASOURCE_USERNAME}
SPRING_DATASOURCE_PASSWORD=${SPRING_DATASOURCE_PASSWORD}
SPRING_DATA_MONGODB_URI=mongodb://${MONGO_USER}:${MONGO_PASSWORD}@${MONGO_HOST}:${MONGO_PORT}/${MONGO_DATABASE}?replicaSet=${MONGO_RS}&tls=true
SPRING_FLYWAY_ENABLED=${SPRING_FLYWAY_ENABLED}
REPORT_PATH=${REPORT_PATH}
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