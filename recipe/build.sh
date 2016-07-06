#!/bin/bash

# grab a list of the packages in the build environment to determine if we are
# building against osmesa or not
CONDA_LST=`conda list`
if [ `uname` = "Darwin" ]; then
    SCREEN_ARGS=(
        "-DVTK_USE_X:BOOL=OFF"
        "-DVTK_USE_COCOA:BOOL=ON"
        "-DVTK_USE_CARBON:BOOL=OFF"
    )
elif [[ ${CONDA_LST}'y' == *'osmesa'* ]]; then
    SCREEN_ARGS=(
        "-DVTK_USE_X:BOOL=OFF"
        "-DVTK_OPENGL_HAS_OSMESA:BOOL=ON"
        "-DOPENGL_INCLUDE_DIR:PATH=${PREFIX}/include"
        "-DOPENGL_gl_LIBRARY:FILEPATH=${PREFIX}/lib/libOSMesa.so"
        "-DOPENGL_glu_LIBRARY:FILEPATH=${PREFIX}/lib/libGLU.so"
        "-DOSMESA_INCLUDE_DIR:PATH=${PREFIX}/include"
        "-DOSMESA_LIBRARY:FILEPATH=${PREFIX}/lib/libOSMesa.so"
    )
else
    SCREEN_ARGS=(
        "-DVTK_USE_X:BOOL=ON"
    )
fi

# FIXME: This is a hack to make sure the environment is activated.
# The reason this is required is due to the conda-build issue
# mentioned below.
#
# https://github.com/conda/conda-build/issues/910
#
source activate "${CONDA_DEFAULT_ENV}"

mkdir build
cd build

BUILD_CONFIG=Release

# sometimes python is suffixed, these are quick fixes to find some variables
# in a future PR we should probably switch to cmake find python scripting
PYTHON_INCLUDE="${PREFIX}/include/python${PY_VER}"
if [ ! -d $PYTHON_INCLUDE ]; then
    PYTHON_INCLUDE="${PREFIX}/include/python${PY_VER}m"
fi

PYTHON_LIBRARY_EXT="so"
if [ `uname` = "Darwin" ] ; then
    PYTHON_LIBRARY_EXT="dylib"
fi

PYTHON_LIBRARY="${PREFIX}/lib/libpython${PY_VER}.${PYTHON_LIBRARY_EXT}"
if [ ! -f $PYTHON_LIBRARY ]; then
    PYTHON_LIBRARY="${PREFIX}/lib/libpython${PY_VER}m.${PYTHON_LIBRARY_EXT}"
fi

# now we can start configuring
cmake .. -G "Ninja" \
    -Wno-dev \
    -DCMAKE_BUILD_TYPE=$BUILD_CONFIG \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DCMAKE_INSTALL_RPATH:PATH="${PREFIX}/lib" \
    -DBUILD_DOCUMENTATION:BOOL=OFF \
    -DBUILD_TESTING:BOOL=OFF \
    -DBUILD_EXAMPLES:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DVTK_ENABLE_VTKPYTHON:BOOL=OFF \
    -DVTK_WRAP_PYTHON:BOOL=ON \
    -DVTK_PYTHON_VERSION:STRING="${PY_VER}" \
    -DVTK_INSTALL_PYTHON_MODULE_DIR:PATH="${SP_DIR}" \
    -DVTK_HAS_FEENABLEEXCEPT:BOOL=OFF \
    -DModule_vtkRenderingMatplotlib=ON \
    -DPYTHON_EXECUTABLE:FILEPATH=$PYTHON \
    -DPYTHON_INCLUDE_DIR:PATH=$PYTHON_INCLUDE \
    -DPYTHON_LIBRARY:FILEPATH=$PYTHON_LIBRARY \
    -DVTK_USE_SYSTEM_ZLIB:BOOL=ON \
    -DVTK_USE_SYSTEM_FREETYPE:BOOL=ON \
    -DVTK_USE_SYSTEM_HDF5:BOOL=ON \
    -DVTK_USE_SYSTEM_LIBXML2:BOOL=ON \
    -DVTK_USE_SYSTEM_PNG:BOOL=ON \
    -DVTK_USE_SYSTEM_JPEG:BOOL=ON \
    -DVTK_USE_SYSTEM_TIFF:BOOL=ON \
    -DVTK_USE_SYSTEM_JSONCPP:BOOL=ON \
    -DVTK_USE_SYSTEM_EXPAT:BOOL=ON \
    ${SCREEN_ARGS[@]}

# compile & install!
ninja install
