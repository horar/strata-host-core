#!/bin/bash
if [ $EUID -ne 0 ]
 then echo "Please run as sudo."
 exit
 fi

 # Terminal constants to highlight our comments
COMMENT_TPUT="tput setaf 2"
COMMENT_RESET="tput sgr0"

# Install spyglass couchbase submodule
$COMMENT_TPUT
echo "Installing couchbase module."
$COMMENT_RESET
sudo git submodule update --init --recursive
# Now install couchbase's submodules
cd ../couchbase-lite-core/
sudo git submodule update --init --recursive

# Install dependent libraries required to compile couchbase
$COMMENT_TPUT
echo "Installing dependency libraries."
$COMMENT_RESET
sudo apt-get install clang -y
sudo apt-get install libicu-dev -y
sudo apt-get install libz-dev -y
sudo apt-get install libc++abi-dev -y
sudo apt-get install libc++-dev -y

# Go through patches that need to be updated

###     couchbase litecore    ###
# Modify CMake to work on ubuntu 16.04. Ubuntu comes with a broken libc++.
# This patch works around this
$COMMENT_TPUT
echo "Installing litecore patches."
$COMMENT_RESET
sudo git am ../submodule_patches/litecore-Make-some-CMake-changes-to-compile-on-Ubuntu-16.04.patch

###     vendor-fleece    ###
$COMMENT_TPUT
echo "Installing fleece patches."
$COMMENT_RESET
# Remove abstract call as gcc complains; Cb uses clang to compile  without complaint
cd ../couchbase-lite-core/vendor/fleece
sudo git am ../../../submodule_patches/fleece-HACK-Remove-abstract-call-as-GCC-complains.patch
sudo git am ../../../submodule_patches/fleece-Correct-fleece-call-of-nullValue.patch
sudo git am ../../../submodule_patches/fleece-Remove-AllocedDict-constructor.patch

###     vendor-BLIP    ###
$COMMENT_TPUT
echo "Installing BLIP patches."
$COMMENT_RESET
# Add #include for condition_variable
cd ../BLIP-Cpp
sudo git am ../../../submodule_patches/blip-Add-condition_variable-include.patch

### BUILD COUCHBASE ###
$COMMENT_TPUT
echo "Building Couchbase litecore."
echo "This will take a few minutes (3-5ish)."
echo "Don't worry, this is just a one time thing."
$COMMENT_RESET
cd ../../build_cmake/scripts/
sudo ./build_macos.sh
###     Completion          ###
$COMMENT_TPUT
echo "Complete!"
$COMMENT_RESET
exit
