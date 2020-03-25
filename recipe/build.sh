#!/bin/bash

mkdir build
cd build || exit

BUILD_CONFIG=Release
OSNAME=$(uname)

# Use bash "Remove Largest Suffix Pattern" to get rid of all but major version number
PYTHON_MAJOR_VERSION=${PY_VER%%.*}

VTK_ARGS=()

if [ -f "$PREFIX/lib/libOSMesa32${SHLIB_EXT}" ]; then
    VTK_ARGS+=(
        "-DVTK_DEFAULT_RENDER_WINDOW_OFFSCREEN:BOOL=ON"
        "-DVTK_OPENGL_HAS_OSMESA:BOOL=ON"
        "-DOSMESA_INCLUDE_DIR:PATH=${PREFIX}/include"
        "-DOSMESA_LIBRARY:FILEPATH=${PREFIX}/lib/libOSMesa32${SHLIB_EXT}"
    )

    if [ "${OSNAME}" == Linux ]; then
        VTK_ARGS+=(
            "-DVTK_USE_X:BOOL=OFF"
            "-DCMAKE_TOOLCHAIN_FILE=${RECIPE_DIR}/cross-linux.cmake"
        )
    elif [ "${OSNAME}" == Darwin ]; then
        VTK_ARGS+=(
            "-DVTK_USE_COCOA:BOOL=OFF"
            "-DCMAKE_OSX_SYSROOT:PATH=${CONDA_BUILD_SYSROOT}"
        )
    fi
else
    VTK_ARGS+=(
        "-DVTK_DEFAULT_RENDER_WINDOW_OFFSCREEN:BOOL=OFF"
        "-DVTK_OPENGL_HAS_OSMESA:BOOL=OFF"
        "-DVTK_USE_TK:BOOL=ON"
    )
    if [ "${OSNAME}" == Linux ]; then
        VTK_ARGS+=(
            "-DVTK_USE_X:BOOL=ON"
            "-DCMAKE_TOOLCHAIN_FILE=${RECIPE_DIR}/cross-linux.cmake"
        )
    elif [ "${OSNAME}" == Darwin ]; then
        VTK_ARGS+=(
            "-DVTK_USE_COCOA:BOOL=ON"
            "-DCMAKE_OSX_SYSROOT:PATH=${CONDA_BUILD_SYSROOT}"
        )
    fi
fi

echo "VTK_ARGS:" "${VTK_ARGS[@]}"

# now we can start configuring
cmake .. -G "Ninja" \
    -Wno-dev \
    -DCMAKE_BUILD_TYPE=$BUILD_CONFIG \
    -DCMAKE_PREFIX_PATH:PATH="${PREFIX}" \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DCMAKE_INSTALL_RPATH:PATH="${PREFIX}/lib" \
    -DCMAKE_INSTALL_LIBDIR:PATH=lib \
    -DVTK_BUILD_DOCUMENTATION:BOOL=OFF \
    -DVTK_BUILD_TESTING:BOOL=OFF \
    -DVTK_BUILD_EXAMPLES:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DVTK_LEGACY_SILENT:BOOL=OFF \
    -DVTK_HAS_FEENABLEEXCEPT:BOOL=OFF \
    -DVTK_WRAP_PYTHON:BOOL=ON \
    -DVTK_PYTHON_VERSION:STRING="${PYTHON_MAJOR_VERSION}" \
    -DPython3_FIND_STRATEGY=LOCATION \
    -DPython3_ROOT_DIR=${PREFIX} \
    -DVTK_MODULE_ENABLE_VTK_PythonInterpreter:STRING=NO \
    -DVTK_MODULE_ENABLE_VTK_RenderingFreeType:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_RenderingMatplotlib:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_IOFFMPEG:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_ViewsCore:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_ViewsContext2D:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_PythonContext2D:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_RenderingContext2D:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_RenderingContextOpenGL2:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_RenderingCore:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_RenderingOpenGL2:STRING=YES \
    -DVTK_DATA_EXCLUDE_FROM_ALL:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtkeigen:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtkdoubleconversion:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtklz4:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtkzlib:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtkexpat:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtkfreetype:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtkjpeg:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtkpng:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtktiff:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtkglew:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtkhdf5:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtkogg:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtktheora:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtkjsoncpp:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtklibxml2:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtklibproj:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtknetcdf:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtklzma:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtkloguru:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtksqlite:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtkutf8:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtkgl2ps:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_vtkpugixml:BOOL=ON \
    "${VTK_ARGS[@]}"

# third-party libraries we'd ideally replace but aren't on conda-forge yet
#-DVTK_MODULE_USE_EXTERNAL_vtklibharu:BOOL=ON \
#-DVTK_MODULE_USE_EXTERNAL_vtkdiy2:BOOL=ON \
#-DVTK_MODULE_USE_EXTERNAL_vtkzfp:BOOL=ON \
#-DVTK_MODULE_USE_EXTERNAL_vtkxdmf2:BOOL=ON \
#-DVTK_MODULE_USE_EXTERNAL_vtkxdmf3:BOOL=ON \
#-DVTK_MODULE_USE_EXTERNAL_vtkpegtl:BOOL=ON \
#-DVTK_MODULE_USE_EXTERNAL_vtkkissfft:BOOL=ON \

# compile & install!
ninja install -v

# The egg-info file is necessary because some packages,
# like mayavi, have a __requires__ in their __invtkRenderWindow::New()it__.py,
# which means pkg_resources needs to be able to find vtk.
# See https://setuptools.readthedocs.io/en/latest/pkg_resources.html#workingset-objects

cat > $SP_DIR/vtk-$PKG_VERSION.egg-info <<FAKE_EGG
Metadata-Version: 2.1
Name: vtk
Version: $PKG_VERSION
Summary: VTK is an open-source toolkit for 3D computer graphics, image processing, and visualization
Platform: UNKNOWN
FAKE_EGG
