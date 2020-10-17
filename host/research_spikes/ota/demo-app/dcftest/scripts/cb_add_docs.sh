#!/usr/bin/env sh

# Add documents from the "documents" dir to Couchbase.
# Tries to download one document, ends with exit code != 0 in case of failure.
# Usage: ./cb_add_docs.sh <COUCHBASE_ENDPOINT> <SYNC_GATEWAY_ENDPOINT>
# ./cb_add_docs.sh "http://127.0.0.1:8091" "http://127.0.0.1:8093/query/service"

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Couchbase server and Sync Gateway endpoints not supplied. Invoke as: ./cb_add_docs.sh <COUCHBASE_ENDPOINT> <SYNC_GATEWAY_ENDPOINT>"
    exit 1
fi

COUCHBASE_ENDPOINT=$1
SYNC_GATEWAY_ENDPOINT=$2

files=./documents/*.json

for file in $files
do
    f=${file%.*}
    f=${f##*/}
    echo "Adding document: $f"
    curl --silent --output /dev/null -X POST -u sync_gateway:sync_gateway $SYNC_GATEWAY_ENDPOINT -d 'statement=UPSERT INTO `strata` (KEY,VALUE) VALUES ("'$f'",  '"$(< $file)"'    )'

    if test "$?" != "0"; then
        echo "Error adding document: $f, aborting."
        exit 1
    fi
done

for file in $files
do
    f=${file%.*}
    f=${f##*/}
    break
done

curl_retries_counter=0
curl_retries_max=30
res=""
while test "$res" != "0" && test "$curl_retries_counter" -lt "$curl_retries_max"; do
    curl --fail --silent --output /dev/null -X GET -u sync_gateway:sync_gateway "$COUCHBASE_ENDPOINT/pools/default/buckets/strata/docs/$f"
    res=$?
    curl_retries_counter=$((curl_retries_counter+1))
    sleep 1
done

if test "$res" != "0"; then
    curl --fail -X GET -u sync_gateway:sync_gateway "$COUCHBASE_ENDPOINT/pools/default/buckets/strata/docs/$f"
fi

exit $res
