#!/usr/bin/env sh
# Copyright (c) 2019-20 Lubomir Carik (Lubomir.Carik@onsemi.com)
#
# Distributed under the MIT License (MIT) (See accompanying file LICENSE.txt
# or copy at http://opensource.org/licenses/MIT)

function usage {
    echo "Syntax:"
    echo "     [-i=BUILD_ID] [-c] [-h]"
    echo "Where:"
    echo "     [-i | --buildid]: For build id"
    echo "     [-c | --cleanup]: To leave only installer"
    echo "     [-h | --help]: For this help"
    echo "For example:"
    echo "     ./bootstrap-host-ota.sh -i=999 --cleanup"
    exit 0
}

#echo "======================================================================="
#echo " Parsing arguments.."
#echo "======================================================================="

BUILD_ID=1
BUILD_CLEANUP=0
BOOTSTRAP_USAGE=0

for i in "$@"
do
case $i in
    -i=*|--buildid=*)
    BUILD_ID="${i#*=}"
    shift # past argument=value
    ;;
    -c|--cleanup)
    BUILD_CLEANUP=1
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

PKG_STRATA=$PACKAGES_DIR/com.onsemi.strata/data
PKG_STRATA_COMPONENTS=$PACKAGES_DIR/com.onsemi.strata.components/data
PKG_STRATA_COMPONENTS_COMMON=$PKG_STRATA_COMPONENTS/imports/tech/strata/commoncpp
PKG_STRATA_COMPONENTS_VIEWS=$PKG_STRATA_COMPONENTS/views
PKG_STRATA_DS=$PACKAGES_DIR/com.onsemi.strata.devstudio/data
PKG_STRATA_HCS=$PACKAGES_DIR/com.onsemi.strata.hcs/data

SDS_BINARY=Strata\ Developer\ Studio.app
HCS_BINARY=hcs
SDS_BINARY_DIR=$PKG_STRATA_DS/$SDS_BINARY
HCS_BINARY_DIR=$PKG_STRATA_HCS/$HCS_BINARY
STRATA_DEPLOYMENT_DIR=../deployment/Strata
STRATA_RESOURCES_DIR=../host/resources/qtifw
STRATA_HCS_CONFIG_DIR=../host/assets/config/hcs
STRATA_CONFIG_XML=$STRATA_RESOURCES_DIR/config/config.xml
MQTT_DLL=QtMqtt
MQTT_DLL_DIR="3p/lib/$MQTT_DLL"
COMMON_CPP_DLL="libcomponent-commoncpp.so"
STRATA_OFFLINE=strata-setup-offline
STRATA_ONLINE=strata-setup-online
STRATA_OFFLINE_BINARY=$STRATA_OFFLINE.app
STRATA_ONLINE_BINARY=$STRATA_ONLINE.app
STRATA_ONLINE_REPO_ROOT=pub
STRATA_ONLINE_REPOSITORY=$STRATA_ONLINE_REPO_ROOT/repository/demo

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

echo "-----------------------------------------------------------------------------"
echo " Actual/local branch list.."
echo "-----------------------------------------------------------------------------"
git branch

echo "======================================================================="
echo " Updating Git submodules.."
echo "======================================================================="
echo git submodule update --init --recursive

echo "-----------------------------------------------------------------------------"
echo " Create a build folder.."
echo "-----------------------------------------------------------------------------"
#if [ -d $BUILD_DIR ] ; then rm -rf $BUILD_DIR; fi
if [ ! -d $BUILD_DIR ] ; then mkdir -pv $BUILD_DIR; fi

echo "======================================================================="
echo " Generating project.."
echo "======================================================================="
cd $BUILD_DIR

if [ -d $PACKAGES_DIR ] ; then rm -rf $PACKAGES_DIR; fi
if [ ! -d $PACKAGES_DIR ] ; then mkdir -pv $PACKAGES_DIR; fi

cmake \
    -DCMAKE_BUILD_TYPE=OTA \
    -DAPPS_TOOLBOX=off \
    -DAPPS_UTILS=off \
    -DBUILD_TESTING=off \
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
# cmake --build . --config Debug

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

echo "======================================================================="
echo " Preparing necessary files.."
echo "======================================================================="

# copy various license files
cp -Rfv $STRATA_DEPLOYMENT_DIR/dependencies/strata/ $PKG_STRATA_DS/

if [ $? != 0 ] ; then 
    echo "======================================================================="
    echo " Failed to copy license files to $PKG_STRATA_DS!"
    echo "======================================================================="
    exit 2
fi

# copy HCS config file
cp -fv $STRATA_HCS_CONFIG_DIR/hcs_prod.config $PKG_STRATA_HCS/hcs.config

if [ $? != 0 ] ; then 
    echo "======================================================================="
    echo " Failed to copy config file to $PKG_STRATA_HCS/hcs.config!"
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

echo "Copying ${MQTT_DLL} to ${PKG_STRATA_COMPONENTS_COMMON}"
cp -fv "${MQTT_DLL_DIR}" "${PKG_STRATA_COMPONENTS_COMMON}"

if [ $? != 0 ] ; then 
    echo "======================================================================="
    echo " Failed to copy ${MQTT_DLL} to ${PKG_STRATA_COMPONENTS_COMMON}!"
    echo "======================================================================="
    exit 2
fi

echo "Performing install_name_tool on ${PKG_STRATA_COMPONENTS_COMMON}/${COMMON_CPP_DLL}"
# Link commoncpp to QtMqtt
install_name_tool \
	-change "${MQTT_DLL_DIR}" "@loader_path/${MQTT_DLL}" \
	"${PKG_STRATA_COMPONENTS_COMMON}/${COMMON_CPP_DLL}"

if [ $? != 0 ] ; then 
    echo "======================================================================="
    echo " Failed to call install_name_tool for ${PKG_STRATA_COMPONENTS_COMMON}/${COMMON_CPP_DLL}!"
    echo "======================================================================="
    exit 2
fi

# TODO (LC):
# - move Frameworks to new module (or not?)
# - update rpaths...
# - move Plugins etc.
# - generate qt.conf with updated paths for ota apps
# - copy non-in resources for ifw-packages ... (icons, banners, scripts, license etc.)

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
    $STRATA_OFFLINE

if [ $? != 0 ] ; then 
    echo "======================================================================="
    echo " Failed to create offline installer $STRATA_OFFLINE_BINARY!"
    echo "======================================================================="
    exit 3
fi

#echo "======================================================================="
#echo " Preparing online installer $STRATA_ONLINE_BINARY.."
#echo "======================================================================="

#binarycreator \
#    --verbose \
#    --online-only \
#    -c $STRATA_CONFIG_XML \
#    -p $PACKAGES_DIR \
#    $STRATA_ONLINE

#if [ $? != 0 ] ; then 
#    echo "======================================================================="
#    echo " Failed to create online installer $STRATA_ONLINE_BINARY!"
#    echo "======================================================================="
#    exit 3
#fi

echo "======================================================================="
echo " Preparing online repository $STRATA_ONLINE_REPOSITORY.."
echo "======================================================================="

if [ -d $STRATA_ONLINE_REPO_ROOT ] ; then rm -rf $STRATA_ONLINE_REPO_ROOT; fi

repogen \
    --update-new-components \
    --verbose \
    -p $PACKAGES_DIR \
    $STRATA_ONLINE_REPOSITORY

if [ $? != 0 ] ; then 
    echo "======================================================================="
    echo " Failed to create online repository $STRATA_ONLINE_REPOSITORY!"
    echo "======================================================================="
    exit 3
fi

if [ $BUILD_CLEANUP != 0 ] ; then
    echo "-----------------------------------------------------------------------------"
    echo " Cleaning build directory"
    echo "-----------------------------------------------------------------------------"
    # TODO
fi

echo "======================================================================="
echo " OTA build finished"
echo "======================================================================="

# how to start/install it..
#   ./strata-setup-offline.app/Contents/MacOS/strata-setup-offline
# how to update or install other component
#   ~/ON\ Semiconductor/Strata/Strata\ Maintenance\ Tool.app/Contents/MacOS/Strata\ Maintenance\ Tool --addRepository $PWD/pub/repository/demo/
