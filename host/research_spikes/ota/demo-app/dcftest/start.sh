#!/usr/bin/env sh

# Starts the Couchbase and a simple file server
# Adds documents to the Couchbase

res="1"
while test "$res" != "0";
do
    ./scripts/up.sh
    ./scripts/cb_setup.sh
    ./scripts/cb_add_docs.sh
    res=$?
    clear
    if test "$res" != "0";
    then
        echo "*******************************"
        echo "* Waiting for CB to start ... *"
        echo "*******************************"
        sleep 1
    else
        echo
        echo "*********************"
        echo "* CB UP and RUNNING *"
        echo "*********************"
        echo
    fi
done

