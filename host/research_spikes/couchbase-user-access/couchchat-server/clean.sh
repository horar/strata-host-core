#!/usr/bin/env sh

# Shuts down the Couchbase and a simple file server.
# Cleans the Couchbase database.

# Check inputs -- project name is required
if [ -z "$1" ]; then
    echo "Error: no argument supplied, check documentation. Invoke as: './clean.sh <project-name>'"
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

docker-compose -f $docker_compose_fileinput down
#If you want to remove the downloaded images, use this command instead:
# docker-compose down -v --rmi all

rm -rf backup/cb
rm -rf backup/nginx-data
