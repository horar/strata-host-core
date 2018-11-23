MUST DO BEFORE BUILD:
======================

Spyglass platform applications located in /platform/applications/
require MBed Operating System libraries and its dependencies.

Dependencies of Mbed OS:

mbed CLI + python utilities
gcc arm toolchain

How to set up your MBed OS enviroment is explained in MbedOSBuilder README file
located in /platform/tools/MbedOSBuilder

This process must be executed before building any platform application!
=========================================================================


HOW TO BUILD:
=============

Inside spyglass directory, create a new directory called "build" and from there run

#Mac, Linux:

```bash
    cd spyglass/
    mkdir build
    cd build
    cmake .. -Dproject_name=water-heater
```

#Windows

cmake .. -G"MinGW Makefiles" -Dproject_name=water-heater

#if you want to specify debug/release build use:

cmake .. -Dproject_name=water-heater -DCMAKE_BUILD_TYPE=release

cmake .. -Dproject_name=water-heater -DCMAKE_BUILD_TYPE=debug



MBED OS:
========

#if you dont want to build mbed OS, this commnad allows you to clone sources as it was done before:

cmake .. -Dproject_name=water-heater -DMBED_OS_CHECKOUT=True

This option supports previous build.

#MBED_OS_VERSION is set in spyglass/build/platform/applications/<project_name>/application.cmake
after you change it, you need delete your CMake cache!

Where water-heater is the project name located in the platform/applications/ directory
and for now we support build of this project only.

#binary file is generated in:

  spyglass/build/platform/applications/<project_name>
