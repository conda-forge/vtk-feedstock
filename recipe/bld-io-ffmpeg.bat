setlocal EnableDelayedExpansion

REM Move vtkIOFFMPEG files to %PREFIX%
for %%d in ("%PREFIX%\..\..") do set "FFMPEG_BASE=%%~fd"
set "FFMPEG_DIR=%FFMPEG_BASE%\vtk_ffmpeg_dir_%PKG_VERSION%_%PY_VER%"
echo FFMPEG_BASE=%FFMPEG_BASE%
echo FFMPEG_DIR=%FFMPEG_DIR%
for /r "%FFMPEG_DIR%" %%f in (*vtkIOFFMPEG*) do (
    set "src=%%f"
    set "rel=!src:%FFMPEG_DIR%\=!"
    echo Installing %%f -^> %PREFIX%\!rel!
    for %%d in ("%PREFIX%\!rel!") do mkdir "%%~dpd" 2>nul
    move "%%f" "%PREFIX%\!rel!"
)
