
mkdir build
cd build

cmake ^
    -GNinja ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DPYTHON_SITELIB=%SP_DIR% ^
    -DPYTHON_EXECUTABLE=%PYTHON% ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
ninja
if errorlevel 1 exit 1

:: Install.
ninja install
if errorlevel 1 exit 1
