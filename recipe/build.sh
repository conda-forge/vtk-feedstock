#!/bin/bash

mkdir build
cd build

BUILD_CONFIG=Release

# choose different screen settings for OS X and Linux
if [ `uname` = "Darwin" ]; then
    SCREEN_ARGS=(
        "-DVTK_USE_X:BOOL=OFF"
        "-DVTK_USE_COCOA:BOOL=ON"
        "-DVTK_USE_CARBON:BOOL=OFF"
    )
else
    SCREEN_ARGS=(
        "-DVTK_USE_X:BOOL=ON"
    )
fi

if [ -f '$PREFIX/lib/libOSMesa32.so']; then
    WITH_OSMESA=(
        "-DVTK_OPENGL_HAS_OSMESA:BOOL=ON"
        "-DOSMESA_LIBRARY=${PREFIX}/lib/libOSMesa32.so"
    )
else
    WITH_OSMESA=()
fi

# now we can start configuring
cmake .. -G "Ninja" \
    -Wno-dev \
    -DCMAKE_BUILD_TYPE=$BUILD_CONFIG \
    -DCMAKE_PREFIX_PATH:PATH="${PREFIX}" \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DCMAKE_INSTALL_RPATH:PATH="${PREFIX}/lib" \
    -DBUILD_DOCUMENTATION:BOOL=OFF \
    -DBUILD_TESTING:BOOL=OFF \
    -DBUILD_EXAMPLES:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DVTK_WRAP_PYTHON:BOOL=ON \
    -DModule_vtkPythonInterpreter:BOOL=OFF \
    -DVTK_PYTHON_VERSION:STRING="${PY_VER}" \
    -DVTK_INSTALL_PYTHON_MODULE_DIR:PATH="${SP_DIR}" \
    -DVTK_HAS_FEENABLEEXCEPT:BOOL=OFF \
    -DVTK_RENDERING_BACKEND=OpenGL2 \
    -DModule_vtkRenderingMatplotlib=ON \
    -DVTK_USE_SYSTEM_ZLIB:BOOL=ON \
    -DVTK_USE_SYSTEM_FREETYPE:BOOL=ON \
    -DVTK_USE_SYSTEM_LIBXML2:BOOL=ON \
    -DVTK_USE_SYSTEM_PNG:BOOL=ON \
    -DVTK_USE_SYSTEM_JPEG:BOOL=ON \
    -DVTK_USE_SYSTEM_TIFF:BOOL=ON \
    -DVTK_USE_SYSTEM_EXPAT:BOOL=ON \
    -DVTK_USE_SYSTEM_HDF5:BOOL=ON \
    -DVTK_USE_SYSTEM_JSONCPP:BOOL=ON \
    -DVTK_SMP_IMPLEMENTATION_TYPE:STRING=TBB \
    ${SCREEN_ARGS[@]} ${WITH_OSMESA[@]}

# compile & install!
ninja install
