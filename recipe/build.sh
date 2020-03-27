#!/bin/bash

mkdir build
cd build || exit

BUILD_CONFIG=Release

# now we can start configuring
cmake .. -G "Ninja" \
    -DCMAKE_BUILD_TYPE=$BUILD_CONFIG

# compile & install!
ninja install -v
