#!/usr/bin/env sh

# Launches desired Couchbase environment
# ./start.sh chatroom-app
# ./start.sh platform-list

COUCHBASE_ENDPOINT="http://127.0.0.1:8091"
SYNC_GATEWAY_ENDPOINT="http://127.0.0.1:8093/query/service"

# Check inputs -- project name is required
if [ -z "$1" ]; then
    echo "Error: no argument supplied, check documentation. Invoke as: './start.sh <project-name>'"
    exit 1
fi

if test "$1" == "chatroom-app"; then
    docker_compose_fileinput="docker-compose-chatroom-app.yml"
elif test "$1" == "platform-list"; then
    docker_compose_fileinput="docker-compose-platform-list.yml"
else
    echo "Error: unrecognized argument supplied, check documentation."
    exit 1
fi

# Check Docker is running
docker_ps=$(docker ps)
if test "$?" != "0"; then
    echo "Error - Docker may not be running, aborting."
    exit 1
fi

echo "Bringing up Couchbase containers..."

./scripts/up.sh $docker_compose_fileinput
couchbase_sg_docker_ps=$(docker-compose --file $docker_compose_fileinput ps -q couchbase)

if test "$?" != "0" || test "$couchbase_sg_docker_ps" == ""; then
    echo "Error bringing up Couchbase containers, aborting."
    exit 1
else
    echo "Couchbase containers up, waiting for services to start (this can take up to 30 seconds)..."
fi

curl_retries_counter=0
curl_retries_max=30
res=""
while test "$res" != "0" && test "$curl_retries_counter" -lt "$curl_retries_max"; do
    curl --silent --output /dev/null $COUCHBASE_ENDPOINT
    res=$?
    curl_retries_counter=$((curl_retries_counter+1))
    sleep 1
done

if test "$res" != "0"; then
    echo "Error: Couchbase services not connected, timed out."
    curl $COUCHBASE_ENDPOINT
    exit 1
fi

# Couchbase setup
echo "Setting up Couchbase server and Sync Gateway for Strata... "
./scripts/cb_setup.sh $COUCHBASE_ENDPOINT

curl_retries_counter=0
res=""
while test "$res" != "0" && test "$curl_retries_counter" -lt "$curl_retries_max"; do
    curl --silent --output /dev/null $SYNC_GATEWAY_ENDPOINT
    res=$?
    curl_retries_counter=$((curl_retries_counter+1))
    sleep 1
done

if test "$res" != "0"; then
    echo "Error: Couchbase setup not successful, timed out."
    curl $SYNC_GATEWAY_ENDPOINT
    exit 1
fi

echo "Couchbase services successfully connected!"
