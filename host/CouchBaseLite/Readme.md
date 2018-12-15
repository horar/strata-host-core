#Couhbase-lite-cpp library
This library depends on couchbase-lite-core. 
Note: This is tested on Mac OS.

Since couchbase-lite-core is submodule please run:
`git submodule update --init --recursive`

Please run the following to build couchbase-lite-core. 
```
cd couchbase-lite-core/build_cmake/scripts
./build_macos.sh
```

#Build
While you are in CouchBaseLite directory run the following:
```
mkdir build && cd build
cmake ..
```

#Run the test/demo
```
./build/couchbase_lite_cpp_test
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
`
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
`