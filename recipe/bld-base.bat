mkdir build
cd build

:: remove -GL from CXXFLAGS
set "CXXFLAGS=-MD"

set PYTHON_MAJOR_VERSION=%PY_VER:~0,1%

cmake .. -G "Ninja" ^
    -Wno-dev ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_LIBDIR="Library/lib" ^
    -DCMAKE_INSTALL_BINDIR="Library/bin" ^
    -DCMAKE_INSTALL_INCLUDEDIR="Library/include" ^
    -DCMAKE_INSTALL_DATAROOTDIR="Library/share" ^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
    -DVTK_PYTHON_SITE_PACKAGES_SUFFIX="Lib/site-packages" ^
    -DBUILD_TESTING:BOOL=OFF ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DVTK_WRAP_PYTHON:BOOL=ON ^
    -DVTK_PYTHON_VERSION:STRING="%PYTHON_MAJOR_VERSION%" ^
    -DPython3_FIND_STRATEGY=LOCATION ^
    -DPython3_ROOT_DIR="%PREFIX%" ^
    -DVTK_BUILD_PYI_FILES:BOOL=ON ^
    -DVTK_HAS_FEENABLEEXCEPT:BOOL=OFF ^
    -DVTK_SMP_IMPLEMENTATION_TYPE:STRING=TBB ^
    -DVTK_DATA_EXCLUDE_FROM_ALL:BOOL=ON ^
    -DVTK_USE_EXTERNAL:BOOL=ON ^
    -DVTK_MODULE_ENABLE_VTK_WebCore:STRING=YES ^
    -DVTK_MODULE_ENABLE_VTK_WebGLExporter:STRING=YES ^
    -DVTK_MODULE_ENABLE_VTK_WebPython:STRING=YES ^
    -DVTK_MODULE_USE_EXTERNAL_VTK_fast_float:BOOL=OFF ^
    -DVTK_MODULE_USE_EXTERNAL_VTK_libharu:BOOL=OFF ^
    -DVTK_MODULE_USE_EXTERNAL_VTK_pegtl:BOOL=OFF ^
    -DVTK_MODULE_USE_EXTERNAL_VTK_exprtk:BOOL=OFF ^
    -DVTK_MODULE_USE_EXTERNAL_VTK_fmt:BOOL=OFF ^
    -DVTK_MODULE_USE_EXTERNAL_VTK_cgns:BOOL=OFF ^
    -DVTK_MODULE_USE_EXTERNAL_VTK_ioss:BOOL=OFF ^
    -DVTK_MODULE_USE_EXTERNAL_VTK_verdict:BOOL=OFF ^
    -DLZMA_LIBRARY="%LIBRARY_PREFIX%/lib/liblzma.lib"
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1

REM The egg-info file is necessary because some packages,
REM like mayavi, have a __requires__ in their __init__.py,
REM which means pkg_resources needs to be able to find vtk.
REM See https://setuptools.readthedocs.io/en/latest/pkg_resources.html#workingset-objects

set egg_info=%SP_DIR%\vtk-%PKG_VERSION%.egg-info
echo>%egg_info% Metadata-Version: 2.1
echo>>%egg_info% Version: %PKG_VERSION%
echo>>%egg_info% Summary: VTK is an open-source toolkit for 3D computer graphics, image processing, and visualization
echo>>%egg_info% Platform: UNKNOWN

if errorlevel 1 exit 1
