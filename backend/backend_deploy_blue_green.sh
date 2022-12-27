#!/bin/bash
set +e

if [ $(docker container ps -f name=blue -q) ]
then
    NEW="green"
    OLD="blue"
else
    NEW="blue"
    OLD="green"
fi

echo "Starting "$NEW" backend"

docker compose --file ~/docker-compose.yml --profile backend-only up --pull=always --detach --force-recreate backend-$NEW

<<comment
for i in {1..20}
do
    sleep 1

    HEALTH=$(docker inspect --format "{{json .State.Health.Status }}" student-backend-1)

    if [[ ${HEALTH} == "healthy"]]
    then
        echo "New '$NEW' service seems OK. "
        sleep 2  # Ensure all requests were processed

        echo "Stopping "$OLD" backend"
        docker compose --file ~/docker-compose.yml --profile backend-only up --pull=always --detach --force-recreate backend-$OLD

        echo "Deployment successful!"
        return 0
    fi

    echo "New '$NEW' service is not ready yet. Waiting ($i)..."

done

echo "New '$NEW' service did not raise, killing it. Failed to deploy T_T"
#docker rm -f $NEW
return 5
comment
