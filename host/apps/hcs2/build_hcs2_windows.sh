#!/bin/bash

cd build
cmake .. -DCROSSCOMPILE=1 -DCMAKE_TOOLCHAIN_FILE=../cmake/x86_64.cmake
make
