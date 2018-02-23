#!/bin/bash

print_usage() {
echo "Missing arguments"
echo "Arguments: <branchname> <output_directory>"
}

COPY_DIR="$(pwd)"

# Check 1st parameter for branchname
if [ "$1" == "" ]
	then
	print_usage
	exit	
else
	BRANCH=$1
fi

# Check 2nd parameter for output directory
if [ "$2" == "" ]
	then
	echo "Using current directory for output"
	COPY_DIR="$(pwd)"
else
	COPY_DIR="$(pwd)//$2"
fi

echo Starting Docker
cd '/c/Program Files/Docker Toolbox/'
# Here documents for longer commands; note: tabs are needed for indentation (no spaces)
start.sh << EOD
	docker run -i -v ~/shared:/shared_data develop_env_container bash<<compileHcs
	cd development/spyglass/host/HostControllerService
	rm -rf build 
	mkdir build
	git fetch
	git checkout origin/$BRANCH --force
	sudo ./build_hcs_windows.sh
	cp build/hcs.exe /shared_data/hcs.exe
	exit
compileHcs
cp ~/shared/hcs.exe $COPY_DIR/hcs.exe
echo "compiling complete"
EOD
