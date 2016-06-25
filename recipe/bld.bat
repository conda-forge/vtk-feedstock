mkdir build
cd build

set BUILD_CONFIG=Release

:: tell cmake where Python is
set PYTHON_LIBRARY=%PREFIX%\libs\python%PY_VER:~0,1%%PY_VER:~2,1%.lib

cmake .. -G "NMake Makefiles" ^
    -Wno-dev ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DBUILD_TESTING:BOOL=OFF ^
    -DBUILD_EXAMPLES:BOOL=OFF ^
    -DBUILD_DOCUMENTATION:BOOL=OFF ^
    -DPYTHON_INCLUDE_DIR:PATH="%PREFIX%/include" ^
    -DPYTHON_LIBRARY:FILEPATH="%PYTHON_LIBRARY%" ^
    -DPYTHON_EXECUTABLE:FILEPATH="%PYTHON%" ^
    -DVTK_BUILD_PYTHON_MODULE_DIR:PATH="%SP_DIR%/vtk" ^
    -DVTK_ENABLE_VTKPYTHON:BOOL=OFF ^
    -DVTK_WRAP_PYTHON:BOOL=ON ^
    -DVTK_PYTHON_VERSION:STRING="%PY_VER%" ^
    -DVTK_INSTALL_PYTHON_MODULE_DIR:PATH="%SP_DIR%" ^
    -DModule_vtkWrappingPythonCore:BOOL=OFF ^
    -DINSTALL_BIN_DIR:PATH="%LIBRARY_BIN%" ^
    -DINSTALL_LIB_DIR:PATH="%LIBRARY_LIB%" ^
    -DINSTALL_INC_DIR:PATH="%LIBRARY_INC%" ^
    -DINSTALL_MAN_DIR:PATH="%LIBRARY_PREFIX%/man"
if errorlevel 1 exit 1

set CL=/MP
nmake install
if errorlevel 1 exit 1
