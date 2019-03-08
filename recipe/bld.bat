mkdir build
cd build

:: remove -GL from CXXFLAGS
set "CXXFLAGS=-MD"

set BUILD_CONFIG=Release

:: tell cmake where Python is
set PYTHON_LIBRARY=%PREFIX%\libs\python%PY_VER:~0,1%%PY_VER:~2,1%.lib

cmake .. -G "Ninja" ^
    -Wno-dev ^
    -DCMAKE_BUILD_TYPE=%BUILD_CONFIG% ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DBUILD_DOCUMENTATION:BOOL=OFF ^
    -DBUILD_TESTING:BOOL=OFF ^
    -DBUILD_EXAMPLES:BOOL=OFF ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DPYTHON_EXECUTABLE:FILEPATH="%PYTHON%" ^
    -DPYTHON_INCLUDE_DIR:PATH="%PREFIX%\include" ^
    -DPYTHON_LIBRARY:FILEPATH="%PYTHON_LIBRARY%" ^
    -DModule_vtkPythonInterpreter:BOOL=OFF ^
    -DVTK_WRAP_PYTHON:BOOL=ON ^
    -DVTK_PYTHON_VERSION:STRING="%PY_VER%" ^
    -DVTK_INSTALL_PYTHON_MODULES_DIR:PATH="%SP_DIR%" ^
    -DVTK_HAS_FEENABLEEXCEPT:BOOL=OFF ^
    -DVTK_RENDERING_BACKEND=OpenGL2 ^
    -DModule_vtkRenderingMatplotlib=ON ^
    -DModule_vtkIOXdmf2:INTERNAL=ON ^
    -DVTK_USE_SYSTEM_ZLIB:BOOL=ON ^
    -DVTK_USE_SYSTEM_FREETYPE:BOOL=ON ^
    -DVTK_USE_SYSTEM_LIBXML2:BOOL=ON ^
    -DVTK_USE_SYSTEM_PNG:BOOL=ON ^
    -DVTK_USE_SYSTEM_JPEG:BOOL=ON ^
    -DVTK_USE_SYSTEM_TIFF:BOOL=ON ^
    -DVTK_USE_SYSTEM_EXPAT:BOOL=ON ^
    -DVTK_USE_SYSTEM_HDF5:BOOL=ON ^
    -DVTK_USE_SYSTEM_JSONCPP:BOOL=ON ^
    -DVTK_USE_SYSTEM_NETCDF:BOOL=ON ^
    -DVTK_USE_SYSTEM_LZ4:BOOL=ON ^
    -DLZ4_LIBRARIES:PATH="%LIBRARY_LIB%\liblz4.lib" ^
    -DVTK_SMP_IMPLEMENTATION_TYPE:STRING=TBB
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1

REM The egg-info file is necessary because some packages,
REM like mayavi, have a __requires__ in their __init__.py,
REM which means pkg_resources needs to be able to find vtk.
REM See https://setuptools.readthedocs.io/en/latest/pkg_resources.html#workingset-objects

set egg_info=%SP_DIR%\vtk-%PKG_VERSION%.egg-info
echo>%egg_info% Metadata-Version: 2.1
echo>>%egg_info% Version: $PKG_VERSION
echo>>%egg_info% Summary: VTK is an open-source toolkit for 3D computer graphics, image processing, and visualization
echo>>%egg_info% Platform: UNKNOWN

if errorlevel 1 exit 1
