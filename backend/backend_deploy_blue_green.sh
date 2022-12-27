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

echo "Starting '$NEW' backend."

docker compose --file ~/docker-compose.yml --profile backend-only up --pull=always --detach --force-recreate backend-$NEW

for i in {1..20}
do
    sleep 1

    OVERALL_HEALTH=$(docker container ps --filter="label=tk.batkovy.deployment=$NEW" --quiet)

    for HEALTH in $OVERALL_HEALTH
    do
        if [[ ${HEALTH} != "healthy"]]
        then
            echo "New '$NEW' service is not ready yet. Waiting ($i)..."
            break
        fi
    done

    echo "New '$NEW' backend seems OK."
    sleep 2  # Ensure all requests were processed

    echo "Stopping "$OLD" backend."
    #docker compose --file ~/docker-compose.yml --profile backend-only up --pull=always --detach --force-recreate backend-$OLD

    echo "Deployment successful!"
    return 0

done

echo "New '$NEW' service did not raise, killing it. Failed to deploy T_T"
return 5