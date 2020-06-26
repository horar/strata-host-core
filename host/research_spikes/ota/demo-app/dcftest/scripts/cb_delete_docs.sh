files=./documents/*.json

for file in $files
do
    f=${file%.*}
    f=${f##*/}
    echo "$f"
    curl -w "%{http_code}\n" -X POST -u sync_gateway:sync_gateway http://127.0.0.1:8093/query/service -d 'statement=DELETE FROM `strata` USE KEYS "'$f'"'
done

