#!/bin/bash
set +e

if [[ $(docker container ps --filter="label=tk.batkovy.deployment=Blue" --quiet) ]]
then
    NEW="green"
    OLD="blue"
else
    NEW="blue"
    OLD="green"
fi

echo "Starting "$NEW" backend."

docker compose --file ~/docker-compose.yml --profile backend-only up --pull=always --detach --force-recreate backend-$NEW
