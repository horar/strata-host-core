#!/usr/bin/env sh

#
# Simple build script for all 'host' targets configured for OTA release
#

#must change working directory, or the relative paths will fail
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
cd ${SCRIPT_DIR}

DEFAULT_ARGUMENTS="--create-installer --generate-repo"
FIXED_ARGUMENTS="--config QA --app --relativerepo --demorepo --nosigning"
CUSTOM_ARGUMENTS="$@"

usage() {
    echo "bootstrap-host-ota.sh is a simple build script for all 'host' targets configured for OTA release"
    echo
    echo "This script call release_app.sh script with 'demo' configuration:"
    echo "  ${DEFAULT_ARGUMENTS} ${FIXED_ARGUMENTS}"
    echo
    echo "Add your own arguments if needed. For example:"
    echo "     ./bootstrap-host-ota.sh -g strata --clean --config PROD --stratarepo http://127.0.0.1/my_strata_repo"
    echo
    echo "To display this help, use:"
    echo "     ./bootstrap-host-ota.sh --help"
    echo
    echo "Displaying now help from release_app.sh:"
    echo
    sh deployment/OTA/Strata/release_app.sh --help
    exit 0
}

USE_DEFAULT_ARGUMENTS=1
for i in "$@"
do
case $i in
    -h|--help)
    usage
    shift # past argument with no value
    ;;
    -g|--generate-repo)
    USE_DEFAULT_ARGUMENTS=0
    shift # past argument with no value
    ;;
    -c|--create-installer)
    USE_DEFAULT_ARGUMENTS=0
    shift # past argument with no value
    ;;
    *)
    shift # past unknown option
    ;;
esac
done

if [[ USE_DEFAULT_ARGUMENTS -eq 0 ]]; then
    sh internal/deployment/OTA/Strata/release_app.sh ${FIXED_ARGUMENTS} ${CUSTOM_ARGUMENTS}
else
    sh internal/deployment/OTA/Strata/release_app.sh ${DEFAULT_ARGUMENTS} ${FIXED_ARGUMENTS} ${CUSTOM_ARGUMENTS}
fi
