#!/usr/bin/env sh

# Add documents from the "documents" dir to Couchbase.
# Tries to download one document, ends with exit code != 0 in case of failure.

files=./documents/*.json

for file in $files
do
    f=${file%.*}
    f=${f##*/}
    echo "Adding document: $f"
    curl -w "%{http_code}\n" -X POST -u sync_gateway:sync_gateway http://127.0.0.1:8093/query/service -d 'statement=UPSERT INTO `strata` (KEY,VALUE) VALUES ("'$f'",  '"$(< $file)"'    )'
done

for file in $files
do
    f=${file%.*}
    f=${f##*/}
    break
done

curl --fail --silent --output /dev/null -w "%{http_code}\n" -X GET -u sync_gateway:sync_gateway "http://127.0.0.1:8091/pools/default/buckets/strata/docs/$f"
