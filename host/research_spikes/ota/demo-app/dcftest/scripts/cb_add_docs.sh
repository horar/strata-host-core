files=./documents/*.json

for file in $files
do
    f=${file%.*}
    f=${f##*/}
    echo "Adding document: $f"
    curl -w "%{http_code}\n" -X POST -u sync_gateway:sync_gateway http://127.0.0.1:8093/query/service -d 'statement=INSERT INTO `strata` (KEY,VALUE) VALUES ("'$f'",  '"$(< $file)"'    )'
done

for file in $files
do
    f=${file%.*}
    f=${f##*/}
    break
done

curl --fail --silent --output /dev/null -w "%{http_code}\n" -X GET -u sync_gateway:sync_gateway "http://127.0.0.1:8091/pools/default/buckets/strata/docs/$f"
