# RS: Bunch of simple shell scripts to produce IFW packages

Couple of simple scripts and configuration files to:
- generate offline/online installer packages
- generate package repository

When all generated and http server is running continue with:
- install app via online or offline app
- increase version in one or more package configuration files
- fire the package script to update package repository
- open maintenance tool installed side-by-side with app
- trigger update action; update...

Note: there is some garbage in configuration files tree
(few redundant files, experiments etc.)


## SW dependencies
### Required
- Qt IFW 3.0+

### Optional
- Qt 5.10+ (for Strata/hcs apps bundling on macOS)
- Python3 (simple http server) or
- Docker (simple http server)

## Compilation
### macOS
Load pre-defined paths setup to local Qt5 and IFW bin folders:
```
cd spyglass/host/research_spikes/ota/shell
. ./macos-setup.sh
```
Opt. build Strata Development Studio and hcs2 server; don't forget to update
hard-coded hcs2 path in main.cpp in Strata project; move them into package structure:
```
./runme-apps.sh
```
Fire packaging helper script:
```
./runme.sh
```
Start simple http server in other terminal:
```
./macos-http.sh
```
or start simple NGINX docker container (in actual 'ota/shell' folder):
```
docker run --name nginx-repo -v $PWD/setup/pub:/usr/share/nginx/html:ro -d -p 8000:80 nginx:1.15.8
```
To inspect nginx access log file:
```
docker logs -f nginx-repo
```

### mingw64 (Win10)
Configure build environment
```
mingw64-setup.bat
```
and fire packaging process:
```
runme.bat
```
Start simple http server in other terminal:
```
mingw64-http.bat
```

## Test
- install online/offline setup
- optionally start maintenance tool stored in installed folder; add/remove optional components...
- back in source tree; e.g. modify some version string (or add new component) in 'ota/shell/setup/packages' subfolders...
- fire packaging helper script again
- start maintenance tool again; choose 'update' action...
