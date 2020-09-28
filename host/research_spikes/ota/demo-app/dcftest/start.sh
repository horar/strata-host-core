#!/usr/bin/env sh

# Starts the Couchbase and a simple file server
# Adds documents to the Couchbase

COUCHBASE_ENDPOINT="http://127.0.0.1:8091"
SYNC_GATEWAY_ENDPOINT="http://127.0.0.1:8093/query/service"

# Check Docker is running
docker_ps=$(docker ps)
if test "$?" != "0"; then
    echo "Error - Docker may not be running, aborting."
    exit 1
fi

echo "Bringing up Couchbase containers...\n"

./scripts/up.sh
couchbase_sg_docker_ps=$(docker-compose ps -q couchbase)

if test "$?" != "0" || test "$couchbase_sg_docker_ps" == ""; then
    echo "\nError bringing up Couchbase containers, aborting."
    exit 1
else
    echo "\nCouchbase containers up, waiting for services to start (this can take up to 30 seconds)..."
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

if test "$res" == "0"; then
    echo "\nCouchbase services successfully connected!"
else
    echo "\nError: Couchbase services not connected, timed out."
    curl $COUCHBASE_ENDPOINT
    exit 1
fi

# Couchbase setup
echo "\nRunning Couchbase setup... "
./scripts/cb_setup.sh $COUCHBASE_ENDPOINT

curl_retries_counter=0
res=""
while test "$res" != "0" && test "$curl_retries_counter" -lt "$curl_retries_max"; do
    curl --silent --output /dev/null $SYNC_GATEWAY_ENDPOINT
    res=$?
    curl_retries_counter=$((curl_retries_counter+1))
    sleep 1
done

if test "$res" == "0"; then
    echo "\nCouchbase services successfully setup!"
else
    echo "\nError: Couchbase setup not successful, timed out."
    curl $SYNC_GATEWAY_ENDPOINT
    exit 1
fi

# Couchbase add docs
echo "\nRunning Couchbase add docs... "
./scripts/cb_add_docs.sh $COUCHBASE_ENDPOINT $SYNC_GATEWAY_ENDPOINT

if test "$?" == "0"; then
    echo "\nCouchbase successfully added docs!"
else
    echo "\nError: Couchbase did not successfully add docs."
    exit 1
fi
