#!/usr/bin/env sh

#
# Simple build script for all 'host' targets configured for OTA release (MacOS)
#
# Copyright (c) 2019-20 Lubomir Carik (Lubomir.Carik@onsemi.com)
#
# Distributed under the MIT License (MIT) (See accompanying file LICENSE.txt
# or copy at http://opensource.org/licenses/MIT)
#

usage() {
    echo "Syntax:"
    echo "     [-i=<BUILD_ID>] [-f=PROD|QA|DEV|DOCKER] [-c] [-s] [-h]"
    echo "Where:"
    echo "     [-i | --buildid]: For build id (Default: 1)"
    echo "     [-c | --cleanup]: To clean build folder before build"
    echo "     [-s | --skiptests]: To skip tests after build"
    echo "     [-f | --config]: To use selected HCS configuration: PROD|QA|DEV|DOCKER (Default: QA)"
    echo "     [-d | --dmg]: To use .dmg installer format (Default: .app)"
    echo "     [-h | --help]: For this help"
    echo "For example:"
    echo "     ./bootstrap-host-ota.sh -i=999 -f=PROD --cleanup -s"
    exit 0
}

#echo "======================================================================="
#echo " Parsing arguments.."
#echo "======================================================================="

BUILD_ID=1
BUILD_CLEANUP=0
SKIP_TESTS=0
USE_PROD_CONFIG=0
USE_QA_CONFIG=0
USE_DEV_CONFIG=0
USE_DOCKER_CONFIG=0
USE_DMG_FORMAT=0
BOOTSTRAP_USAGE=0

for i in "$@"
do
case $i in
    -i=*|--buildid=*)
    BUILD_ID="${i#*=}"
    shift # past argument=value
    ;;
    -f=*|--config=*)
    SELECTED_CONFIG="${i#*=}"
    if [ "${SELECTED_CONFIG}" = "PROD" ] ; then
        USE_PROD_CONFIG=1
    elif [ "${SELECTED_CONFIG}" = "QA" ] ; then
        USE_QA_CONFIG=1
    elif [ "${SELECTED_CONFIG}" = "DEV" ] ; then
        USE_DEV_CONFIG=1
    elif [ "${SELECTED_CONFIG}" = "DOCKER" ] ; then
        USE_DOCKER_CONFIG=1
    else
        BOOTSTRAP_USAGE=1
    fi
    shift # past argument=value
    ;;
    -c|--cleanup)
    BUILD_CLEANUP=1
    shift # past argument with no value
    ;;
    -s|--skiptests)
    SKIP_TESTS=1
    shift # past argument with no value
    ;;
    -d|--dmg)
    USE_DMG_FORMAT=1
    shift # past argument with no value
    ;;
    -h|--help)
    BOOTSTRAP_USAGE=1
    shift # past argument with no value
    ;;
    *)
    BOOTSTRAP_USAGE=1
    shift # past unknown option
    ;;
esac
done

if [ $BOOTSTRAP_USAGE != 0 ] ; then usage; fi

echo "======================================================================="
echo " Preparing environment.."
echo "======================================================================="

BUILD_DIR=build-host-ota
PACKAGES_DIR=packages
export BUILD_ID

APP_FORMAT=app
DMG_FORMAT=dmg

STRATA=strata
STRATA_COMPONENTS=components
STRATA_DS=devstudio
STRATA_HCS=hcs

MODULE_STRATA=com.onsemi.$STRATA
MODULE_STRATA_COMPONENTS=$MODULE_STRATA.$STRATA_COMPONENTS
MODULE_STRATA_DS=$MODULE_STRATA.$STRATA_DS
MODULE_STRATA_HCS=$MODULE_STRATA.$STRATA_HCS

PKG_STRATA=$PACKAGES_DIR/$MODULE_STRATA/data
PKG_STRATA_COMPONENTS=$PACKAGES_DIR/$MODULE_STRATA_COMPONENTS/data
PKG_STRATA_COMPONENTS_COMMON=$PKG_STRATA_COMPONENTS/imports/tech/strata/commoncpp
PKG_STRATA_COMPONENTS_VIEWS=$PKG_STRATA_COMPONENTS/views
PKG_STRATA_DS=$PACKAGES_DIR/$MODULE_STRATA_DS/data
PKG_STRATA_HCS=$PACKAGES_DIR/$MODULE_STRATA_HCS/data

SDS_BINARY=Strata\ Developer\ Studio.$APP_FORMAT
HCS_BINARY=hcs
SDS_BINARY_DIR=$PKG_STRATA_DS/$SDS_BINARY
HCS_BINARY_DIR=$PKG_STRATA_HCS/$HCS_BINARY
STRATA_DEPLOYMENT_DIR=../deployment/Strata
STRATA_RESOURCES_DIR=../host/resources/qtifw

STRATA_HCS_CONFIG_FILE_PROD=hcs_prod.config
STRATA_HCS_CONFIG_FILE_QA=hcs_qa.config
STRATA_HCS_CONFIG_FILE_DEV=hcs_dev.config
STRATA_HCS_CONFIG_FILE_DOCKER=hcs_docker.config
STRATA_HCS_CONFIG_FILE=${STRATA_HCS_CONFIG_FILE_QA}

if [ $USE_PROD_CONFIG != 0 ] ; then
    STRATA_HCS_CONFIG_FILE=${STRATA_HCS_CONFIG_FILE_PROD}
elif [ $USE_QA_CONFIG != 0 ] ; then
    STRATA_HCS_CONFIG_FILE=${STRATA_HCS_CONFIG_FILE_QA}
elif [ $USE_DEV_CONFIG != 0 ] ; then
    STRATA_HCS_CONFIG_FILE=${STRATA_HCS_CONFIG_FILE_DEV}
elif [ $USE_DOCKER_CONFIG != 0 ] ; then
    STRATA_HCS_CONFIG_FILE=${STRATA_HCS_CONFIG_FILE_DOCKER}
fi

STRATA_CONFIG_XML=$STRATA_RESOURCES_DIR/config/config.xml
MQTT_LIB=QtMqtt
COMMON_CPP_LIB="libcomponent-commoncpp.so"
INSTALLERBASE_BINARY=installerbase
INSTALLERBASE_BINARY_DIR=$PKG_STRATA/$INSTALLERBASE_BINARY
STRATA_OFFLINE=strata-setup-offline
STRATA_ONLINE=strata-setup-online
STRATA_OFFLINE_BINARY=$STRATA_OFFLINE.$APP_FORMAT
STRATA_ONLINE_BINARY=$STRATA_ONLINE.$APP_FORMAT
if [ $USE_DMG_FORMAT != 0 ] ; then
    STRATA_OFFLINE_BINARY=$STRATA_OFFLINE.$DMG_FORMAT
    STRATA_ONLINE_BINARY=$STRATA_ONLINE.$DMG_FORMAT
fi

STRATA_ONLINE_REPOSITORY=public/repository/demo

echo "-----------------------------------------------------------------------------"
echo " Build env. setup:"
echo "-----------------------------------------------------------------------------"

echo " Checking clang..."
if [ ! -x "$(command -v clang)" ]; then
    echo "======================================================================="
    echo " clang is missing from path! Aborting."
    echo "======================================================================="
    exit 1
fi

clang --version
echo "-----------------------------------------------------------------------------"

echo " Checking cmake..."
if [ ! -x "$(command -v cmake)" ]; then
    echo "======================================================================="
    echo " cmake is missing from path! Aborting."
    echo "======================================================================="
    exit 1
fi

cmake --version
echo "-----------------------------------------------------------------------------"

echo " Checking qmake..."
if [ ! -x "$(command -v qmake)" ]; then
    echo "======================================================================="
    echo " qmake is missing from path! Aborting."
    echo "======================================================================="
    exit 1
fi

qmake --version
echo "-----------------------------------------------------------------------------"

echo " Checking QtIFW binarycreator..."
if [ ! -x "$(command -v binarycreator)" ]; then
    echo "======================================================================="
    echo " QtIFW's binarycreator is missing from path! Aborting."
    echo "======================================================================="
    exit 1
fi

echo " Checking QtIFW repogen..."
if [ ! -x "$(command -v repogen)" ]; then
    echo "======================================================================="
    echo " QtIFW's repogen is missing from path! Aborting."
    echo "======================================================================="
    exit 1
fi

echo " Checking QtIFW installerbase..."
if [ ! -x "$(command -v installerbase)" ]; then
    echo "======================================================================="
    echo " QtIFW's installerbase is missing from path! Aborting."
    echo "======================================================================="
    exit 1
fi

INSTALLERBASE_BINARY_ORIG_DIR=$(command -v installerbase | head -n 1)
echo   Detected location: $INSTALLERBASE_BINARY_ORIG_DIR

echo " Checking Qt macdeployqt..."
if [ ! -x "$(command -v macdeployqt)" ]; then
    echo "======================================================================="
    echo " Qt's macdeployqt is missing from path! Aborting."
    echo "======================================================================="
    exit 1
fi

echo " Checking install_name_tool..."
if [ ! -x "$(command -v install_name_tool)" ]; then
    echo "======================================================================="
    echo " install_name_tool is missing from path! Aborting."
    echo "======================================================================="
    exit 1
fi

echo " Checking otool..."
if [ ! -x "$(command -v otool)" ]; then
    echo "======================================================================="
    echo " otool is missing from path! Aborting."
    echo "======================================================================="
    exit 1
fi

echo "-----------------------------------------------------------------------------"
echo " Actual/local branch list.."
echo "-----------------------------------------------------------------------------"
git branch

if [ $BUILD_CLEANUP != 0 ] ; then
    if [ -d $BUILD_DIR ] ; then
        echo "-----------------------------------------------------------------------------"
        echo " Cleaning build directory"
        echo "-----------------------------------------------------------------------------"
        rm -rf $BUILD_DIR;
    fi
fi

echo "-----------------------------------------------------------------------------"
echo " Create a build folder.."
echo "-----------------------------------------------------------------------------"
if [ ! -d $BUILD_DIR ] ; then mkdir -pv $BUILD_DIR; fi

echo "======================================================================="
echo " Generating project.."
echo "======================================================================="
cd $BUILD_DIR

if [ -d $PACKAGES_DIR ] ; then rm -rf $PACKAGES_DIR; fi
if [ ! -d $PACKAGES_DIR ] ; then mkdir -pv $PACKAGES_DIR; fi

cmake \
    -DCMAKE_BUILD_TYPE=OTA \
    -DAPPS_CORESW_HCS_CONFIG:STRING=${STRATA_HCS_CONFIG_FILE} \
    -DAPPS_TOOLBOX=off \
    -DAPPS_UTILS=off \
    -DBUILD_TESTING=on \
    ../host

if [ $? != 0 ] ; then
    echo "======================================================================="
    echo " Failed to configure cmake build!"
    echo "======================================================================="
    exit 4
fi

echo "======================================================================="
echo " Compiling.."
echo "======================================================================="
cmake --build . -- -j $(sysctl -n hw.ncpu)

if [ $? != 0 ] ; then
    echo "======================================================================="
    echo " Failed to perform cmake build!"
    echo "======================================================================="
    exit 5
fi

if [ ! -d "$SDS_BINARY_DIR" ] ; then
    echo "======================================================================="
    echo " Missing $SDS_BINARY, build probably failed"
    echo "======================================================================="
    exit 2
fi

if [ ! -f "$HCS_BINARY_DIR" ] ; then
    echo "======================================================================="
    echo " Missing $HCS_BINARY, build probably failed"
    echo "======================================================================="
    exit 2
fi

if [ $SKIP_TESTS -eq 0 ] ; then
    echo "======================================================================="
    echo " Starting Strata unit tests.."
    echo "======================================================================="

    ctest

    if [ $? != 0 ] ; then
        echo "======================================================================="
        echo " Unit tests failed!"
        echo "======================================================================="
        exit 6
    fi
fi

echo "======================================================================="
echo " Preparing necessary files.."
echo "======================================================================="

# copy various license files
if [ ! -d $PKG_STRATA ] ; then mkdir -pv $PKG_STRATA; fi

cp -Rfv $STRATA_DEPLOYMENT_DIR/dependencies/strata/ $PKG_STRATA/

if [ $? != 0 ] ; then
    echo "======================================================================="
    echo " Failed to copy license files to $PKG_STRATA!"
    echo "======================================================================="
    exit 2
fi

# echo "Copying Qt Core/Components resources to $PKG_STRATA_COMPONENTS"
# cp -fv ./bin/component-*.rcc $PKG_STRATA_COMPONENTS

echo "Copying Qml Views Resources to $PKG_STRATA_COMPONENTS_VIEWS"
if [ ! -d $PKG_STRATA_COMPONENTS_VIEWS ] ; then mkdir -pv $PKG_STRATA_COMPONENTS_VIEWS; fi
cp -fv ./bin/views-*.rcc $PKG_STRATA_COMPONENTS_VIEWS

if [ $? != 0 ] ; then
    echo "======================================================================="
    echo " Failed to copy views to $PKG_STRATA_COMPONENTS_VIEWS!"
    echo "======================================================================="
    exit 2
fi

echo "Copying ${MQTT_LIB} to ${PKG_STRATA_COMPONENTS_COMMON}"
MQTT_LIB_DIR_ACTUAL=$(otool -L "${PKG_STRATA_COMPONENTS_COMMON}/${COMMON_CPP_LIB}" | grep ${MQTT_LIB} | sed -e 's/^[ 	\t]*//;s/ (compatibility.*//')

cp -fv "${MQTT_LIB_DIR_ACTUAL}" "${PKG_STRATA_COMPONENTS_COMMON}"

if [ $? != 0 ] ; then
    echo "======================================================================="
    echo " Failed to copy ${MQTT_LIB_DIR_ACTUAL} to ${PKG_STRATA_COMPONENTS_COMMON}!"
    echo "======================================================================="
    exit 2
fi

echo "Performing install_name_tool on ${PKG_STRATA_COMPONENTS_COMMON}/${COMMON_CPP_LIB}"
# Link commoncpp to QtMqtt
echo "Changing ${MQTT_LIB_DIR_ACTUAL} to @loader_path/${MQTT_LIB}"
install_name_tool \
    -change "${MQTT_LIB_DIR_ACTUAL}" "@loader_path/${MQTT_LIB}" \
    "${PKG_STRATA_COMPONENTS_COMMON}/${COMMON_CPP_LIB}"

# This is a bit problematic because there are no errors thrown even if it does not finds anything
if [ $? != 0 ] ; then
    echo "======================================================================="
    echo " Failed to call install_name_tool for ${PKG_STRATA_COMPONENTS_COMMON}/${COMMON_CPP_LIB}!"
    echo "======================================================================="
    exit 2
fi

echo Copying ${INSTALLERBASE_BINARY_ORIG_DIR} to ${INSTALLERBASE_BINARY_DIR}
cp -fv "${INSTALLERBASE_BINARY_ORIG_DIR}" "${INSTALLERBASE_BINARY_DIR}"

if [ $? != 0 ] ; then
    echo "======================================================================="
    echo " Failed to copy ${INSTALLERBASE_BINARY_ORIG_DIR} to ${INSTALLERBASE_BINARY_DIR}!"
    echo "======================================================================="
    exit 2
fi

echo "-----------------------------------------------------------------------------"
echo " Preparing $SDS_BINARY dependencies.."
echo "-----------------------------------------------------------------------------"

macdeployqt "$SDS_BINARY_DIR" \
    -qmldir=../host/apps/DeveloperStudio \
    -qmldir=../host/components \
    -verbose=1

if [ $? != 0 ] ; then
    echo "======================================================================="
    echo " Failed to macdeployqt $SDS_BINARY!"
    echo "======================================================================="
    exit 3
fi

echo "-----------------------------------------------------------------------------"
echo " Preparing $HCS_BINARY dependencies.."
echo "-----------------------------------------------------------------------------"

#if the build does not fails, the errors can be ignored
macdeployqt "$PKG_STRATA_HCS" \
    -executable="$HCS_BINARY_DIR" \
    -no-plugins \
    -verbose=1

if [ $? != 0 ] ; then
    echo "======================================================================="
    echo " Failed to macdeployqt $HCS_BINARY!"
    echo "======================================================================="
    exit 3
fi

echo "======================================================================="
echo " Preparing offline installer $STRATA_OFFLINE_BINARY.."
echo "======================================================================="

binarycreator \
    --verbose \
    --offline-only \
    -c $STRATA_CONFIG_XML \
    -p $PACKAGES_DIR \
    $STRATA_OFFLINE_BINARY

if [ $? != 0 ] ; then
    echo "======================================================================="
    echo " Failed to create offline installer $STRATA_OFFLINE_BINARY!"
    echo "======================================================================="
    exit 3
fi

echo "======================================================================="
echo " Preparing online installer $STRATA_ONLINE_BINARY.."
echo "======================================================================="

binarycreator \
    --verbose \
    --online-only \
    -c $STRATA_CONFIG_XML \
    -p $PACKAGES_DIR \
    $STRATA_ONLINE_BINARY

if [ $? != 0 ] ; then
    echo "======================================================================="
    echo " Failed to create online installer $STRATA_ONLINE_BINARY!"
    echo "======================================================================="
    exit 3
fi

echo "======================================================================="
echo " Preparing online repository $STRATA_ONLINE_REPOSITORY.."
echo "======================================================================="

if [ -d $STRATA_ONLINE_REPOSITORY ] ; then rm -rf $STRATA_ONLINE_REPOSITORY; fi
if [ ! -d $STRATA_ONLINE_REPOSITORY ] ; then mkdir -pv $STRATA_ONLINE_REPOSITORY; fi

echo "-----------------------------------------------------------------------------"
echo " Preparing online repository $STRATA_ONLINE_REPOSITORY/$STRATA.."
echo "-----------------------------------------------------------------------------"

repogen --verbose -p $PACKAGES_DIR --include $MODULE_STRATA $STRATA_ONLINE_REPOSITORY/$STRATA
if [ $? != 0 ] ; then
    echo "======================================================================="
    echo " Failed to create online repository $STRATA_ONLINE_REPOSITORY/$STRATA!"
    echo "======================================================================="
    exit 3
fi

echo "-----------------------------------------------------------------------------"
echo " Updating online repository $STRATA_ONLINE_REPOSITORY/$STRATA/Updates.xml.."
echo "-----------------------------------------------------------------------------"

if [ ! -f "$STRATA_ONLINE_REPOSITORY/$STRATA/Updates.xml" ] ; then
    echo "======================================================================="
    echo " Missing $STRATA_ONLINE_REPOSITORY/$STRATA/Updates.xml, repogen probably failed"
    echo "======================================================================="
    exit 2
fi

cp $STRATA_ONLINE_REPOSITORY/$STRATA/Updates.xml $STRATA_ONLINE_REPOSITORY/$STRATA/Updates.xml.bak
sed '$ d' $STRATA_ONLINE_REPOSITORY/$STRATA/Updates.xml.bak > $STRATA_ONLINE_REPOSITORY/$STRATA/Updates.xml
rm -f $STRATA_ONLINE_REPOSITORY/$STRATA/Updates.xml.bak

echo " <RepositoryUpdate>
  <Repository action=\"add\" url=\"../${STRATA_COMPONENTS}\" displayname=\"Module $MODULE_STRATA_COMPONENTS\"/>
  <Repository action=\"add\" url=\"../${STRATA_DS}\" displayname=\"Module $MODULE_STRATA_DS\"/>
  <Repository action=\"add\" url=\"../${STRATA_HCS}\" displayname=\"Module $MODULE_STRATA_HCS\"/>
 </RepositoryUpdate>
</Updates>" >> $STRATA_ONLINE_REPOSITORY/$STRATA/Updates.xml

echo "-----------------------------------------------------------------------------"
echo " Preparing online repository $STRATA_ONLINE_REPOSITORY/$STRATA_COMPONENTS.."
echo "-----------------------------------------------------------------------------"
repogen --verbose -p $PACKAGES_DIR --include $MODULE_STRATA_COMPONENTS $STRATA_ONLINE_REPOSITORY/$STRATA_COMPONENTS
if [ $? != 0 ] ; then
    echo "======================================================================="
    echo " Failed to create online repository $STRATA_ONLINE_REPOSITORY/$STRATA_COMPONENTS!"
    echo "======================================================================="
    exit 3
fi

echo "-----------------------------------------------------------------------------"
echo " Preparing online repository $STRATA_ONLINE_REPOSITORY/$STRATA_DS.."
echo "-----------------------------------------------------------------------------"
repogen --verbose -p $PACKAGES_DIR --include $MODULE_STRATA_DS $STRATA_ONLINE_REPOSITORY/$STRATA_DS
if [ $? != 0 ] ; then
    echo "======================================================================="
    echo " Failed to create online repository $STRATA_ONLINE_REPOSITORY/$STRATA_DS!"
    echo "======================================================================="
    exit 3
fi

echo "-----------------------------------------------------------------------------"
echo " Preparing online repository $STRATA_ONLINE_REPOSITORY/$STRATA_HCS.."
echo "-----------------------------------------------------------------------------"
repogen --verbose -p $PACKAGES_DIR --include $MODULE_STRATA_HCS $STRATA_ONLINE_REPOSITORY/$STRATA_HCS
if [ $? != 0 ] ; then
    echo "======================================================================="
    echo " Failed to create online repository $STRATA_ONLINE_REPOSITORY/$STRATA_HCS!"
    echo "======================================================================="
    exit 3
fi

echo "======================================================================="
echo " OTA build finished"
echo "======================================================================="

# how to start/install it..
#   ./strata-setup-offline.app/Contents/MacOS/strata-setup-offline
# how to update or install other component
#   ~/ON\ Semiconductor/Strata/Strata\ Maintenance\ Tool.app/Contents/MacOS/Strata\ Maintenance\ Tool --addRepository $PWD/pub/repository/demo/
