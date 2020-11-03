#!/usr/bin/env sh

# Sets parameters for the Couchbase server.
# Usage: ./cb_setup.sh <COUCHBASE_ENDPOINT>
# ./cb_setup.sh "http://127.0.0.1:8091"

if [ -z "$1" ]; then
    echo "Error: Couchbase server endpoint not supplied. Invoke as: ./cb_setup.sh <COUCHBASE_ENDPOINT>"
    exit 1
fi

COUCHBASE_ENDPOINT=$1

echo Initialize Node
out=$(curl -s -w "%{http_code}\n" -X POST $COUCHBASE_ENDPOINT/nodes/self/controller/settings -d 'path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata&index_path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata&java_home=')

echo Rename Node
out=$(curl -s -w "%{http_code}\n" -X POST -u sync_gateway:sync_gateway $COUCHBASE_ENDPOINT/node/controller/rename -d 'hostname=127.0.0.1')

echo Indexes
out=$(curl -s -w "%{http_code}\n" -X POST -u sync_gateway:sync_gateway $COUCHBASE_ENDPOINT/settings/indexes -d 'storageMode=forestdb')

echo Pools Default
out=$(curl -s -w "%{http_code}\n" -X POST -u sync_gateway:sync_gateway $COUCHBASE_ENDPOINT/pools/default -d 'clusterName=user-access-test&memoryQuota=312&indexMemoryQuota=512&ftsMemoryQuota=256')

echo Setup Services
out=$(curl -s -w "%{http_code}\n" -X POST -u sync_gateway:sync_gateway $COUCHBASE_ENDPOINT/node/controller/setupServices -d 'services=kv%2Cindex%2Cn1ql%2Cfts')

echo Stats
out=$(curl -s -w "%{http_code}\n" -X POST -u sync_gateway:sync_gateway $COUCHBASE_ENDPOINT/settings/stats -d 'sendStats=true')

echo Setup Administrator username and password
out=$(curl -s -w "%{http_code}\n" -X POST -u sync_gateway:sync_gateway $COUCHBASE_ENDPOINT/settings/web -d 'password=sync_gateway&username=sync_gateway&port=SAME')

echo Create bucket
out=$(curl -s -w "%{http_code}\n" -X POST -u sync_gateway:sync_gateway $COUCHBASE_ENDPOINT/pools/default/buckets -d name=user-access-test -d ramQuotaMB=100 -d authType=none)
