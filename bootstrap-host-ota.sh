#!/usr/bin/env sh
# Copyright (c) 2019-20 Lubomir Carik (Lubomir.Carik@onsemi.com)
#
# Distributed under the MIT License (MIT) (See accompanying file LICENSE.txt
# or copy at http://opensource.org/licenses/MIT)

# exit on first error
set -e

echo "-----------------------------------------------------------------------------"
echo "Build env. setup:"
echo "-----------------------------------------------------------------------------"
clang --version
echo "-----------------------------------------------------------------------------"
cmake --version
echo "-----------------------------------------------------------------------------"
qmake --version
echo "-----------------------------------------------------------------------------"
echo "Checking QtIFW binarycreator..."
if [ ! -x "$(command -v binarycreator)" ]; then
    echo "QtIFW's binarycreator is missing from path! Aborting."
    exit
fi
echo "Checking QtIFW repogen..."
if [ ! -x "$(command -v repogen)" ]; then
    echo "QtIFW's repogen is missing from path! Aborting."
    exit
fi

echo "-----------------------------------------------------------------------------"
echo "Actual/local branch list.."
echo "-----------------------------------------------------------------------------"
git branch

echo "-----------------------------------------------------------------------------"
echo "Updating Git submodules.."
echo "-----------------------------------------------------------------------------"
git submodule update --init --recursive

echo "-----------------------------------------------------------------------------"
echo "Create a build folder.."
echo "-----------------------------------------------------------------------------"
mkdir -pv build-host-ota
cd build-host-ota

echo "-----------------------------------------------------------------------------"
echo "Generate project files.."
echo "-----------------------------------------------------------------------------"
cmake \
    -DCMAKE_BUILD_TYPE=OTA \
    -DAPPS_CORESW=on \
    -DAPPS_CORECOMPONENTS=on \
    -DAPPS_TOOLBOX=off \
    -DAPPS_UTILS=off \
    -DAPPS_VIEWS=off \
    -DBUILD_DONT_CLEAN_EXTERNAL=on \
    -DBUILD_EXAMPLES=off \
    -DBUILD_TESTING=off \
    ../host
if [ $? != 0 ] ; then exit -1; fi

echo "-----------------------------------------------------------------------------"
echo "Build project.."
echo "-----------------------------------------------------------------------------"
cmake --build . -- -j $(sysctl -n hw.ncpu)




# TODO (LC):
# - move Frameworks to new module (or not?)
# - update rpaths...
# - move Plugins etc.
# - generate qt.conf with updated paths for ota apps
# - copy non-in resources for ifw-packages ... (icons, banners, scripts, license etc.)




macdeployqt ./packages/com.onsemi.strata.devstudio/data/Strata\ Developer\ Studio.app \
    -qmldir=../host/apps/DeveloperStudio \
    -qmldir=../host/components \
    -verbose=1

binarycreator \
    --verbose \
    --offline-only \
    -c ../host/resources/qtifw/config/config.xml \
    -p ./packages/ \
    strata-setup-offline


#binarycreator \
#    --verbose \
#    --online-only \
#    -c ../resources/qtifw/config/config.xml \
#    -p ./packages/ \
#    strata-setup-online

repogen \
    --update-new-components \
    -p ./packages pub/repository/demo


# how to start/install it..
#   ./strata-setup-offline.app/Contents/MacOS/strata-setup-offline
# how to update or install other component
#   ~/ON\ Semiconductor/Strata/Strata\ Maintenance\ Tool.app/Contents/MacOS/Strata\ Maintenance\ Tool --addRepository $PWD/pub/repository/demo/
