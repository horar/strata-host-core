#!/usr/bin/env sh
# Copyright (c) 2019 Lubomir Carik (Lubomir.Carik@onsemi.com)
#
# Distributed under the MIT License (MIT) (See accompanying file LICENSE.txt
# or copy at http://opensource.org/licenses/MIT)

# exit on firts error
set -e

echo "-----------------------------------------------------------------------------"
echo "Build env. setup:"
echo "-----------------------------------------------------------------------------"
clang --version
echo "-----------------------------------------------------------------------------"
cmake --version
echo "-----------------------------------------------------------------------------"
qmake --version

# actual branch list
echo "-----------------------------------------------------------------------------"
echo "Actual/local brnch list.."
echo "-----------------------------------------------------------------------------"
git branch

# updating Git submodules
echo "-----------------------------------------------------------------------------"
echo "Updateing Git submodules.."
echo "-----------------------------------------------------------------------------"
git submodule update --init --recursive

# create a build folder if necessary
echo "-----------------------------------------------------------------------------"
echo "Create a build folder.."
echo "-----------------------------------------------------------------------------"
mkdir -pv build
cd build

# generate a project file
echo "-----------------------------------------------------------------------------"
echo "Generate project files.."
echo "-----------------------------------------------------------------------------"
cmake -DCMAKE_BUILD_TYPE=Debug ..
if [ $? != 0 ] ; then exit -1; fi

# Build (ie 'make')
echo "-----------------------------------------------------------------------------"
echo "Build project.."
echo "-----------------------------------------------------------------------------"
cmake --build . -- -j $(sysctl -n hw.ncpu)
