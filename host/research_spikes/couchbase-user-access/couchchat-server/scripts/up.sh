#!/usr/bin/env sh

# Starts the Couchbase and file server. If given, uses docker-compose fileinput as argument
# ./up.sh <docker_compose_fileinput>

if [ -z "$1" ]; then
    docker-compose up -d
else
    docker-compose --file $1 up -d
fi
