#
# Sample app build setup script for macOS
# 
# Note: don't forgot to update hardcoded path to hcs2 in Strata project (main.cpp)
#
#
# (c) 2019, Lubomir Carik
#

echo Building apps...
mkdir -p build
cd build

cmake -DCMAKE_BUILD_TYPE=Release ../../../../
cmake --build . --target strata -- -j5
cmake --build . --target hcs2 -- -j5
cd bin

macdeployqt Strata\ Development\ Studio.app/ -qmldir=../../../../../apps/strata/

mv Strata\ Development\ Studio.app/ ../../setup/packages/tech.spyglass.strata.ui/data/

mv hcs2 ../../setup/packages/tech.spyglass.strata.hcs2.osx/data/
cp ../../../../../apps/hcs2/files/conf/host_controller_service.config_template ../../setup/packages/tech.spyglass.strata.hcs2.osx/data
