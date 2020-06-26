Docker container structure to simmulate sub-set of Strata infrastructure on localhost.

- Couchbase, with few pre-defined documents, you can add/modify documents as required
- Fileserver (nginx), you can add files as required

Only for local development.

Startup:

Before startup, update CB documents in ```./documents/``` and hosted files in ```./files/```.
```
    ./start.sh
```
It takes some time for CB to start, the script is retrying connections.

Shut down:
```
    ./clean.sh
```

To inspect the log files:
```
    docker-compose logs -f
```

Connecting Strata:

0. stop HCS
1. change HCS config to contain:
```
    "database":{
        "file_server":"http://localhost:8000",
        "gateway_sync":"ws://localhost:4984/strata"
    }
```
2. build HCS
3. run ```host/build/bin/hcs -c``` to clear CB cache
4. set up ```./documents/``` and ```./files/``` as needed
5. run ```./start.sh``` and wait for CB to start
6. run HCS

CB server is running at:

- http://localhost:8091
- un:pass is sync_gateway:sync_gateway

Sync gateway is running at:

- http://localhost:4984
- ws://localhost:4984

Fileserver is running at:

- http://localhost:8000

Directories:

- ```documents``` - these documents will be put into CB on startup. E.g. 201.json will be under the key "201"
- ```files``` - files hosted in the fileserver
- ```conf``` - configuration files for sync gateway and nginx

Sample setup:

The CB setup commited here is for testing FW update info. If you add ```bubu2-debug-300-v100.bin``` and ```bubu2-debug-300-v101.bin``` files into the ```files``` dir, you will be able to test flashing firmware, with 2 available binaries.
