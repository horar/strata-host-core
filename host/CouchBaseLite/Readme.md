#Couhbase-lite-cpp library
This library depends on couchbase-lite-core. 
Note: This is tested on Mac OS.
Please run the following to build couchbase-lite-core. 
```
cd couchbase-lite-core/build_cmake
./build_macos.sh
```

#Build
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