#!/usr/bin/env sh

#
# Simple build script for all 'host' targets configured for OTA release
#

#must change working directory, or the relative paths will fail
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
cd ${SCRIPT_DIR}

FIXED_ARGUMENTS="--create-installer --generate-repo --config QA --app --relativerepo --demorepo --nosigning"
CUSTOM_ARGUMENTS="$@"

usage() {
    echo "bootstrap-host-ota.sh is a simple build script for all 'host' targets configured for OTA release"
    echo
    echo "This script call release_app.sh script with 'demo' configuration:"
    echo "  ${FIXED_ARGUMENTS}"
    echo
    echo "Add your own arguments if needed. For example:"
    echo "     ./bootstrap-host-ota.sh --clean --stratarepo http://127.0.0.1/my_strata_repo"
	echo
    echo "To display this help, use:"
    echo "     ./bootstrap-host-ota.sh --help"
    echo
    echo "Displaying now help from release_app.sh:"
    echo
    sh deployment/OTA/Strata/release_app.sh --help
    exit 0
}

for i in "$@"
do
case $i in
    -h|--help)
    usage
    shift # past argument with no value
    ;;
    *)
    shift # past unknown option
    ;;
esac
done

sh deployment/OTA/Strata/release_app.sh ${FIXED_ARGUMENTS} ${CUSTOM_ARGUMENTS}
