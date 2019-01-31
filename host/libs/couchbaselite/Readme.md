#Couhbase-lite-cpp library
This library depends on couchbase-lite-core. 
SGDatabase and SGReplicator have thread safe functions. Please see the .h files for more details.


Note: This is tested on Mac OS and (Windows built using Visual Studio).

Since couchbase-lite-core is submodule of this library please run:
`git submodule update --init --recursive`

Due to large library sizes for couchbase-lite-core. The library is added as subdirectory and it will be built on the fly when building this library! 

#Build
Go to spyglass/host:
```
mkdir build && cd build
cmake ..
```

#Run the example demos from spyglass/host/build/app
```
./fleece-playground
./sgcouchbaselite-playground
```

DB location will be inside build/db/${dbname}/db.sqlite3.
The db can be viewed using any sqlite viewer.
sqlitebrowser is a good choice!



#Couchbase backend technologies
- Install Couchbase server (community edition) from `https://www.couchbase.com/downloads`. 
This library was tested with Couchbase version `5.5.1`
- Install Sync Gateway 2.1.1 from above link
- Follow sync gateway instructions setup from `https://docs.couchbase.com/sync-gateway/2.1/getting-started.html`
- NOTE: Use the following configuration file and change information as needed.
```JSON
{
    "log": ["*"],
    "databases": {
        "staging": {
            "server": "http://localhost:8091",
            "bucket": "staging",
            "username": "sync_gateway",
            "password": "sync_gateway",
            "enable_shared_bucket_access": true,
            "import_docs": "continuous",
            "num_index_replicas": 0,
            "users": {
              "GUEST": {
                "disabled": false, "admin_channels": ["*"]
              },
              "username": {
                "disabled": false, "admin_channels": ["*"], "password":"password"
              }
            }
        }
    }
}
```

#TODO:
1. Unit Tests.
2. Improve/reuse Log. This can be done by doing some refactoring/file restructures on other projects which has better log.