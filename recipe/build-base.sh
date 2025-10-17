#!/bin/bash

set -ex

BUILD_CONFIG=Release

# Use bash "Remove Largest Suffix Pattern" to get rid of all but major version number
PYTHON_MAJOR_VERSION=${PY_VER%%.*}

if [[ "${target_platform}" =~ osx-arm64 && "${target_platform}" != "${build_platform}" ]]; then
    rm -f "${PREFIX}/lib/qt6/moc"
    ln -s "${BUILD_PREFIX}/lib/qt6/moc" "${PREFIX}/lib/qt6/moc"

    # Additional debugging information
    echo "Adjusted Qt tools for osx-arm64 with build variant qt6"
    echo "Removed: ${PREFIX}/lib/qt6/moc"
    echo "Linked to: ${BUILD_PREFIX}/lib/qt6/moc"
else
    echo "Skipping Qt tools adjustment. Target platform: ${target_platform}"
fi

VTK_ARGS=()

if [[ "${target_platform}" == linux-* ]]; then
    VTK_ARGS+=(
        "-DVTK_USE_X:BOOL=ON"
        "-DOPENGL_opengl_LIBRARY:FILEPATH=${PREFIX}/lib/libGL.so.1"
        "-DVTK_OPENGL_HAS_EGL:BOOL=ON"
        "-DOPENGL_egl_LIBRARY:FILEPATH=${PREFIX}/lib/libEGL.so.1"
    )
elif [[ "${target_platform}" == osx-* ]]; then
    VTK_ARGS+=(
        "-DVTK_USE_COCOA:BOOL=ON"
        "-DCMAKE_OSX_SYSROOT:PATH=${CONDA_BUILD_SYSROOT}"
        "-DVTK_MODULE_USE_EXTERNAL_VTK_gl2ps:BOOL=OFF"
    )
fi

if [[ "$target_platform" != "linux-ppc64le" ]]; then
    VTK_ARGS+=(
        "-DVTK_MODULE_ENABLE_VTK_GUISupportQt:STRING=YES"
        "-DVTK_MODULE_ENABLE_VTK_RenderingQt:STRING=YES"
    )
fi

if [[ "$target_platform" == osx-* ]]; then
    # incompatible function pointers become errors in clang >=16
    export CFLAGS="${CFLAGS} -Wno-incompatible-pointer-types"
    export CXXFLAGS="${CXXFLAGS} -Wno-incompatible-pointer-types"
fi

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
  (
    mkdir build-native
    cd build-native
    export CC=$CC_FOR_BUILD
    export CXX=$CXX_FOR_BUILD
    unset CFLAGS
    unset CXXFLAGS
    unset CPPFLAGS
    export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
    cmake -G Ninja -DCMAKE_INSTALL_PREFIX=$SRC_DIR/vtk-compile-tools \
       -DCMAKE_PREFIX_PATH=$BUILD_PREFIX \
       -DCMAKE_INSTALL_LIBDIR=lib \
       -DVTK_BUILD_COMPILE_TOOLS_ONLY=ON ..
    ninja -j${CPU_COUNT}
    ninja install -j${CPU_COUNT}
    cd ..
  )
  MAJ_MIN=$(echo $PKG_VERSION | rev | cut -d"." -f2- | rev)
  CMAKE_ARGS="${CMAKE_ARGS} -DVTKCompileTools_DIR=$SRC_DIR/vtk-compile-tools/lib/cmake/vtkcompiletools-${MAJ_MIN}/"
  CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_REQUIRE_LARGE_FILE_SUPPORT=1 -DCMAKE_REQUIRE_LARGE_FILE_SUPPORT__TRYRUN_OUTPUT="
  CMAKE_ARGS="${CMAKE_ARGS} -DVTK_REQUIRE_LARGE_FILE_SUPPORT_EXITCODE=0 -DVTK_REQUIRE_LARGE_FILE_SUPPORT_EXITCODE__TRYRUN_OUTPUT="
  CMAKE_ARGS="${CMAKE_ARGS} -DXDMF_REQUIRE_LARGE_FILE_SUPPORT_EXITCODE=0 -DXDMF_REQUIRE_LARGE_FILE_SUPPORT_EXITCODE__TRYRUN_OUTPUT="
fi

# Only build pyi files when natively compiling
if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
  CMAKE_ARGS="${CMAKE_ARGS} -DVTK_BUILD_PYI_FILES:BOOL=OFF"
else
  CMAKE_ARGS="${CMAKE_ARGS} -DVTK_BUILD_PYI_FILES:BOOL=ON"
fi

mkdir build
cd build || exit

echo "VTK_ARGS:" "${VTK_ARGS[@]}"

# now we can start configuring
cmake -LAH .. -G "Ninja" ${CMAKE_ARGS} \
    -Wno-dev \
    -DCMAKE_BUILD_TYPE=$BUILD_CONFIG \
    -DCMAKE_PREFIX_PATH:PATH="${PREFIX}" \
    -DCMAKE_FIND_FRAMEWORK=LAST \
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
    -DVTK_WRAP_SERIALIZATION:BOOL=ON \
    -DVTK_PYTHON_VERSION:STRING="${PYTHON_MAJOR_VERSION}" \
    -DPython3_EXECUTABLE=$PYTHON \
    -DVTK_DEFAULT_RENDER_WINDOW_OFFSCREEN:BOOL=OFF \
    -DVTK_USE_TK:BOOL=ON \
    -DVTK_SMP_ENABLE_TBB:BOOL=ON \
    -DVTK_ENABLE_VISKORES_OVERRIDES:BOOL=ON \
    -DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKmFilters:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_cli11=YES \
    -DVTK_MODULE_ENABLE_VTK_FiltersParallelDIY2:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_FiltersParallelStatistics=YES \
    -DVTK_MODULE_ENABLE_VTK_FiltersParallelVerdict=YES \
    -DVTK_MODULE_ENABLE_VTK_IOAvmesh:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_IOFFMPEG:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_IOH5part:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_IOH5Rage:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_IOOMF:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_IOParallelExodus:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_IOParallelLSDyna:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_IOPIO:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_IOTRUCHAS:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_IOVPIC:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_IOXdmf2:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_IOXdmf3:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_PythonContext2D:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_PythonInterpreter:STRING=NO \
    -DVTK_MODULE_ENABLE_VTK_RenderingContext2D:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_RenderingContextOpenGL2:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_RenderingCore:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_RenderingFreeType:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_RenderingMatplotlib:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_RenderingOpenGL2:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_RenderingParallel:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_RenderingVolumeAMR:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_ViewsContext2D:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_ViewsCore:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_WebCore:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_WebGLExporter:STRING=YES \
    -DVTK_MODULE_ENABLE_VTK_WebPython:STRING=YES \
    -DVTK_USE_EXTERNAL:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_fast_float:BOOL=OFF \
    -DVTK_MODULE_USE_EXTERNAL_VTK_libharu:BOOL=OFF \
    -DVTK_MODULE_USE_EXTERNAL_VTK_loguru:BOOL=OFF \
    -DVTK_MODULE_USE_EXTERNAL_VTK_pegtl:BOOL=OFF \
    -DVTK_MODULE_USE_EXTERNAL_VTK_exprtk:BOOL=OFF \
    -DVTK_MODULE_USE_EXTERNAL_VTK_fmt:BOOL=ON \
    -DVTK_MODULE_USE_EXTERNAL_VTK_cgns:BOOL=OFF \
    -DVTK_MODULE_USE_EXTERNAL_VTK_ioss:BOOL=OFF \
    -DVTK_MODULE_USE_EXTERNAL_VTK_token:BOOL=OFF \
    -DVTK_MODULE_USE_EXTERNAL_VTK_verdict:BOOL=OFF \
    -DQT_HOST_PATH:STRING="${PREFIX}" \
    "${VTK_ARGS[@]}"

# compile & install!
ninja install -j${CPU_COUNT} -v

# Create a directory for the vtk-io-ffmpeg package
# and find the ffmpeg-related files and process each of them
FFMPEG_DIR="$(dirname $(dirname $PREFIX))/vtk_ffmpeg_dir_${PKG_VERSION}_${PY_VER}"
mkdir -p "$FFMPEG_DIR"
find $PREFIX -name "*vtkIOFFMPEG*" -print0 | while IFS= read -r -d '' file; do
    dest_dir="$FFMPEG_DIR/${file#$PREFIX/}"
    mkdir -p "$(dirname "$dest_dir")"
    mv "$file" "$dest_dir"
done


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

# The METADATA file is necessary to ensure that pip list shows the pip package installed by conda
# The INSTALLER file is necessary to ensure that pip list shows that the package is installed by conda
# See https://packaging.python.org/specifications/recording-installed-packages/
# and https://packaging.python.org/en/latest/specifications/core-metadata/#core-metadata

mkdir $SP_DIR/vtk-$PKG_VERSION.dist-info

cat > $SP_DIR/vtk-$PKG_VERSION.dist-info/METADATA <<METADATA_FILE
Metadata-Version: 2.1
Name: vtk
Version: $PKG_VERSION
Summary: VTK is an open-source toolkit for 3D computer graphics, image processing, and visualization
METADATA_FILE

cat > $SP_DIR/vtk-$PKG_VERSION.dist-info/INSTALLER <<INSTALLER_FILE
conda
INSTALLER_FILE
