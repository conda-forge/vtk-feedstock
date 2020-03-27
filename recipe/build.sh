#!/bin/bash

# from opencv-feedstock
# CMake FindPNG seems to look in libpng not libpng16
# https://gitlab.kitware.com/cmake/cmake/blob/master/Modules/FindPNG.cmake#L55
ln -s $PREFIX/include/libpng16 $PREFIX/include/libpng

mkdir build
cd build || exit

BUILD_CONFIG=Release

# now we can start configuring
cmake .. -G "Ninja" \
    -DCMAKE_BUILD_TYPE=$BUILD_CONFIG \
    -DCMAKE_PREFIX_PATH=$PREFIX

# compile & install!
ninja install -v
