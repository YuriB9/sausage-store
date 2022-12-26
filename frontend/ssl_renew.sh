#!/bin/bash

COMPOSE="/usr/bin/docker compose --ansi never --file /home/student/sausage-store/docker-compose.yml"
DOCKER="/usr/bin/docker"

$COMPOSE run certbot renew --dry-run -v && \
    $COMPOSE --profile frontend-only restart frontend
    
$DOCKER system prune -af