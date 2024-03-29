#! /bin/bash
#Если свалится одна из команд, рухнет и весь скрипт
set -xe
#Перезаливаем дескриптор сервиса на ВМ для деплоя
sudo cp -rf sausage-store-frontend-user.service /home/front-user/.config/systemd/user/sausage-store-frontend-user.service
sudo rm -f /home/front-user/sausage-store-front.tar.gz||true
#Переносим артефакт в нужную папку
curl -u ${NEXUS_REPO_USER}:${NEXUS_REPO_PASS} -o sausage-store-front.tar.gz ${NEXUS_REPO_URL}/repository/09-sausage-store-batkov-yuriy-frontend/sausage-store/${VERSION}/sausage-store-${VERSION}.tar.gz
sudo cp ./sausage-store-front.tar.gz /home/front-user/sausage-store-front.tar.gz||true
sudo tar -xf /home/front-user/sausage-store-front.tar.gz -C /var/www-data/dist/
#Обновляем конфиг systemd с помощью рестарта
systemctl --user daemon-reload
#Перезапускаем сервис сосисочной
systemctl --user restart sausage-store-frontend-user.service