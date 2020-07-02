#!/usr/bin/env sh

# Sets parameters for the Couchbase server.

echo Initialize Node
curl -w "%{http_code}\n" -X POST http://127.0.0.1:8091/nodes/self/controller/settings -d 'path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata&index_path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata&java_home='

echo Rename Node
curl -w "%{http_code}\n" -X POST -u sync_gateway:sync_gateway http://127.0.0.1:8091/node/controller/rename -d 'hostname=127.0.0.1'

echo Indexes
curl -w "%{http_code}\n" -X POST -u sync_gateway:sync_gateway http://127.0.0.1:8091/settings/indexes -d 'storageMode=forestdb'

echo Pools Default
curl -w "%{http_code}\n" -X POST -u sync_gateway:sync_gateway http://127.0.0.1:8091/pools/default -d 'clusterName=strata&memoryQuota=312&indexMemoryQuota=512&ftsMemoryQuota=256'

echo Setup Services
curl -w "%{http_code}\n" -X POST -u sync_gateway:sync_gateway http://127.0.0.1:8091/node/controller/setupServices -d 'services=kv%2Cindex%2Cn1ql%2Cfts'

echo Stats
curl -w "%{http_code}\n" -X POST -u sync_gateway:sync_gateway http://127.0.0.1:8091/settings/stats -d 'sendStats=true'

echo Setup Administrator username and password
curl -w "%{http_code}\n" -X POST -u sync_gateway:sync_gateway http://127.0.0.1:8091/settings/web -d 'password=sync_gateway&username=sync_gateway&port=SAME'

echo create bucket
curl -w "%{http_code}\n" -X POST -u sync_gateway:sync_gateway http://127.0.0.1:8091/pools/default/buckets -d name=strata -d ramQuotaMB=100 -d authType=none

