#!/usr/bin/env sh
# Copyright (c) 2019 Lubomir Carik (Lubomir.Carik@onsemi.com)
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
    ../host
if [ $? != 0 ] ; then exit -1; fi

echo "-----------------------------------------------------------------------------"
echo "Build project.."
echo "-----------------------------------------------------------------------------"
cmake --build . -- -j $(sysctl -n hw.ncpu)
