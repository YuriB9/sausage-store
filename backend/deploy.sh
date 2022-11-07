#! /bin/bash
#Если свалится одна из команд, рухнет и весь скрипт
set -xe
#Перезаливаем дескриптор сервиса на ВМ для деплоя
sudo cp -rf sausage-store-backend-user.service /home/jarservice/.config/systemd/user/sausage-store-backend-user.service
sudo rm -f /home/jarservice/sausage-store.jar||true
#Переносим артефакт в нужную папку
curl -u ${NEXUS_REPO_USER}:${NEXUS_REPO_PASS} -o sausage-store.jar ${NEXUS_REPO_URL}/repository/09-sausage-store-batkov-yuriy-backend/com/yandex/practicum/devops/sausage-store/${VERSION}/sausage-store-${VERSION}.jar
sudo cp ./sausage-store.jar /home/jarservice/sausage-store.jar||true #"jar||true" говорит, если команда обвалится — продолжай

systemctl --user set-environment PSQL_DBNAME=${PSQL_DBNAME} PSQL_USER=${PSQL_USER} PSQL_PASSWORD=${PSQL_PASSWORD} PSQL_HOST=${PSQL_HOST} PSQL_PORT=${PSQL_PORT}
#
#Обновляем конфиг systemd с помощью рестарта
systemctl --user daemon-reload
#Перезапускаем сервис сосисочной
systemctl --user restart sausage-store-backend-user.service
