#!/usr/bin/env sh
# Copyright (c) 2019-20 Lubomir Carik (Lubomir.Carik@onsemi.com)
#
# Distributed under the MIT License (MIT) (See accompanying file LICENSE.txt
# or copy at http://opensource.org/licenses/MIT)


echo "======================================================================="
echo " Preparing environment.."
echo "======================================================================="

# exit on first error
set -e

echo "-----------------------------------------------------------------------------"
echo " Build env. setup:"
echo "-----------------------------------------------------------------------------"
clang --version
echo "-----------------------------------------------------------------------------"
cmake --version
echo "-----------------------------------------------------------------------------"
qmake --version
echo "-----------------------------------------------------------------------------"
echo " Checking QtIFW binarycreator..."
if [ ! -x "$(command -v binarycreator)" ]; then
    echo "QtIFW's binarycreator is missing from path! Aborting."
    exit
else
    echo "QtIFW's binarycreator found"
fi
echo " Checking QtIFW repogen..."
if [ ! -x "$(command -v repogen)" ]; then
    echo "QtIFW's repogen is missing from path! Aborting."
    exit
else
    echo "QtIFW's repogen found"
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
#if [ -d build-host-ota ] ; then rm -rf build-host-ota; fi
if [ ! -d build-host-ota ] ; then mkdir -pv build-host-ota; fi

echo "======================================================================="
echo " Generating project.."
echo "======================================================================="
cd build-host-ota

if [ -d packages ] ; then rm -rf packages; fi
if [ ! -d packages ] ; then mkdir -pv packages; fi

cmake \
    -DCMAKE_BUILD_TYPE=OTA \
    -DCMAKE_BUILD_TYPE=OTA \
    -DAPPS_TOOLBOX=off \
    -DAPPS_UTILS=off \
    -DBUILD_TESTING=off \
    ../host

if [ $? != 0 ] ; then exit -1; fi

echo "======================================================================="
echo " Compiling.."
echo "======================================================================="
cmake --build . -- -j $(sysctl -n hw.ncpu)
# cmake --build . --config Debug

if [ ! -d ./packages/com.onsemi.strata.devstudio/data/Strata\ Developer\ Studio.app ] ; then 
    echo "======================================================================="
    echo " Missing Strata Developer Studio.app, build probably failed"
    echo "======================================================================="
    exit 2
fi

if [ ! -f ./packages/com.onsemi.strata.hcs/data/hcs ] ; then 
    echo "======================================================================="
    echo " Missing hcs, build probably failed"
    echo "======================================================================="
    exit 2
fi

echo "======================================================================="
echo " Copying necessary files.."
echo "======================================================================="

# copy various license files
cp -fv ../deployment/Strata/dependencies/strata/* ./packages/com.onsemi.strata.devstudio/data

# echo "Copying Qt Core/Components resources to ./packages/com.onsemi.strata.components/data"
# cp -fv ./bin/component-*.rcc ./packages/com.onsemi.strata.components/data

echo "Copying Qml Views Resources to ./packages/com.onsemi.strata.components/data/views"
if [ ! -d ./packages/com.onsemi.strata.components/data/views ] ; then mkdir -pv ./packages/com.onsemi.strata.components/data/views; fi
cp -fv ./bin/views-*.rcc ./packages/com.onsemi.strata.components/data/views

#if [ ! -f ./bin/Qt5Mqtt.so ] ; then 
#    echo "======================================================================="
#    echo " Missing Qt5Mqtt.so, build probably failed"
#    echo "======================================================================="
#    exit 2
#fi

#echo "Copying QtMqtt.so to main dir"
#cp -fv ./bin/Qt5Mqtt.so ./packages/com.onsemi.strata.devstudio/data


# TODO (LC):
# - move Frameworks to new module (or not?)
# - update rpaths...
# - move Plugins etc.
# - generate qt.conf with updated paths for ota apps
# - copy non-in resources for ifw-packages ... (icons, banners, scripts, license etc.)

echo "-----------------------------------------------------------------------------"
echo " Preparing Strata Developer Studio.app dependencies.."
echo "-----------------------------------------------------------------------------"

macdeployqt ./packages/com.onsemi.strata.devstudio/data/Strata\ Developer\ Studio.app \
    -qmldir=../host/apps/DeveloperStudio \
    -qmldir=../host/components \
    -libpath=./packages/com.onsemi.strata.qt/data \
    -libpath=./packages/com.onsemi.strata.qt/data/plugins \
    -verbose=1

echo "======================================================================="
echo " Preparing offline installer.."
echo "======================================================================="

binarycreator \
    --verbose \
    --offline-only \
    -c ../host/resources/qtifw/config/config.xml \
    -p ./packages \
    strata-setup-offline
	
#echo "======================================================================="
#echo " Preparing online installer.."
#echo "======================================================================="

#binarycreator \
#    --verbose \
#    --online-only \
#    -c ../host/resources/qtifw/config/config.xml \
#    -p ./packages \
#    strata-setup-online

echo "======================================================================="
echo " Preparing online repository.."
echo "======================================================================="

if [ -d pub ] ; then rm -rf pub; fi

repogen \
    --update-new-components \
    --verbose \
    -p ./packages \
    pub/repository/demo

echo "======================================================================="
echo " OTA build finished"
echo "======================================================================="

# how to start/install it..
#   ./strata-setup-offline.app/Contents/MacOS/strata-setup-offline
# how to update or install other component
#   ~/ON\ Semiconductor/Strata/Strata\ Maintenance\ Tool.app/Contents/MacOS/Strata\ Maintenance\ Tool --addRepository $PWD/pub/repository/demo/
