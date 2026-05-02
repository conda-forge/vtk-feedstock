setlocal EnableDelayedExpansion

REM Move vtkIOFFMPEG files to %PREFIX%
set "FFMPEG_DIR=%SRC_DIR%\vtk_ffmpeg_dir_%PKG_VERSION%_%PY_VER%"
for /r "%FFMPEG_DIR%" %%f in (*vtkIOFFMPEG*) do (
    set "src=%%f"
    set "rel=!src:%FFMPEG_DIR%\=!"
    for %%d in ("%PREFIX%\!rel!") do mkdir "%%~dpd" 2>nul
    move "%%f" "%PREFIX%\!rel!"
)
