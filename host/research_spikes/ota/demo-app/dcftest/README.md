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

Shut down and clean:
```
    ./clean.sh
```

Shut down without clean:
```
    ./scripts/down.sh
```

To inspect the log files:
```
    docker-compose logs -f
```

Connecting Strata:

0. stop HCS
1. run ```host/build/bin/hcs -c``` to clear CB cache
2. set up ```./documents/``` and ```./files/``` as needed
3. run ```./start.sh``` and wait for CB to start
4. (if running only HCS) run HCS with configuration in ```<PROJECT_ROOT>/host/assets/config/hcs/hcs_docker.config```, i.e. ```<BUILD_DIR>/bin/hcs -f <PATH_TO_CONFIG>/hcs_docker.config```
5. (if running the Developer Studio) compile strata source code with CMake option APPS_CORESW_HCS_CONFIG=hcs_docker.config option setup.

CB server is running at:

- http://localhost:8091
- Couchbase credentials (username:password) are sync_gateway:sync_gateway

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
