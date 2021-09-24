#!/usr/bin/env sh
##
## Copyright (c) 2018-2021 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##

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
echo "Actual/local branch list.."
echo "-----------------------------------------------------------------------------"
git --no-pager branch

echo "-----------------------------------------------------------------------------"
echo "Updating Git submodules.."
echo "-----------------------------------------------------------------------------"
git submodule update --init --recursive

echo "-----------------------------------------------------------------------------"
echo "Create a build folder.."
echo "-----------------------------------------------------------------------------"
mkdir -pv build-host
cd build-host

echo "-----------------------------------------------------------------------------"
echo "Generate project files.."
echo "-----------------------------------------------------------------------------"
cmake \
    -DCMAKE_BUILD_TYPE=Debug \
    ..
if [ $? != 0 ] ; then exit -1; fi

echo "-----------------------------------------------------------------------------"
echo "Build project.."
echo "-----------------------------------------------------------------------------"
cmake --build . -- -j $(sysctl -n hw.ncpu)
