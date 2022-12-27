#!/bin/bash
set +e

if [[ $(docker container ps --filter="label=tk.batkovy.deployment=blue" --quiet) ]]
then
    NEW="green"
    OLD="blue"
else
    NEW="blue"
    OLD="green"
fi

echo "Start '$NEW' backend."

docker compose --file ~/docker-compose.yml --profile backend-only up --pull=always --detach --force-recreate backend-$NEW

for i in {1..60}
do
    sleep 5s

    ALL_CONTAINERS=$(docker container ps --filter="label=tk.batkovy.deployment=$NEW" --quiet)
    HEALTHY_CONTAINERS=$(docker container ps --filter="label=tk.batkovy.deployment=$NEW" --filter="health=healthy" --quiet)

    if [[ $ALL_CONTAINERS != $HEALTHY_CONTAINERS ]]
    then
        echo "'$NEW' backend is not ready yet. Waiting '$i'..."
    else
        echo "'$NEW' backend seems OK."

        echo "Stop '$OLD' backend."
        docker compose --file ~/docker-compose.yml --profile backend-only stop backend-$OLD

        break
    fi

done

if [[ $ALL_CONTAINERS != $HEALTHY_CONTAINERS ]]
then
    echo "New '$NEW' backend failed to deploy."
else
    echo "Deployment successful!"
fi