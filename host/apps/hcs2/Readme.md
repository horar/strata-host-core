# Host Controller Service 2

Host Controller Service(HCS) is the edge to the cloud in the "Spyglass" project. It communicates with cloud services, platform and client programs(UI, CLI).

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

#### Linux (couchbase)

HCS uses/creates a local database  using [couchbase-lite-core](https://github.com/couchbase/couchbase-lite-core) engine. The litecore.so should be built before building HCS

Inside spyglass,

```
cd cloud/submodule_patches/
sudo ./configure_couchbase.sh
```

####Windows

We are currently cross compiling for windows from linux. Hence downloading mingw toolchain is essential. In linux terminal please follow these steps
```
sudo apt-get install mingw-w64
```
### Installing

A step by step series of examples that tell you have to get a development env running

Say what the step will be

Inside spyglass folder,

```
cd host
mkdir build
cd build
```

####Linux and MAC

```
cmake ..
```

####Windows

We are currently cross compiling for windows from linux. To get the makefile for windows with cross compiling toolchain follow this step

```
cmake .. -DCROSSCOMPILE=1 -DCMAKE_TOOLCHAIN_FILE=../cmake/x86_64.cmake
```

####Building on all machines
```
make
```

## Deployment

####Linux and MAC

Before deploying, user needs to have a config file that sets the destination socket and cloud bucket that HCS needs to communicate with. The template for the config file is available in "host/apps/hcs2/files/conf". Create a copy of this config file.

```
cd host/apps/hcs2/files/conf
cp host_controller_service.config_template host_controller_service.config
```

Now deploy in the terminal,

```
cd host/build/
sudo ./apps/hcs2/hcs2 -f ../apps/hcs2/files/conf/host_controller_service.config
```

## Built With

* [zeromq](https://github.com/zeromq/libzmq) - ZEROMQ socket
* [libserialport](https://sigrok.org/wiki/Libserialport) - Serial devices IO library
* [libevent](http://libevent.org/) - Event based library
* [couchbase-lite-core](https://github.com/couchbase/couchbase-lite-core) -


## Authors

* **Ian Cain** - *Bossman*
* **Prasanth Vivek** - *HCS core developer*
* **Abe Lopez** - *LiteCore integration*
