#!/usr/bin/env sh

# Shuts down the Couchbase and a simple file server.
# Cleans the Couchbase database.

docker-compose down
#If you want to remove the downloaded images, use this command instead:
# docker-compose down -v --rmi all

rm -rf backup/cb
rm -rf backup/nginx-data
