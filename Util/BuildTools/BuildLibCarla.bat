@echo off
setlocal

rem BAT script that creates the client and the server of LibCarla (carla.org).
rem Run it through a cmd with the x64 Visual C++ Toolset enabled.

set LOCAL_PATH=%~dp0
set "FILE_N=-[%~n0]:"

rem Print batch params (debug purpose)
echo %FILE_N% [Batch params]: %*

rem ============================================================================
rem -- Parse arguments ---------------------------------------------------------
rem ============================================================================

set DOC_STRING=Build LibCarla.
set "USAGE_STRING=Usage: %FILE_N% [-h^|--help] [--rebuild] [--server] [--client] [--clean]"

set REMOVE_INTERMEDIATE=false
set BUILD_SERVER=false
set BUILD_CLIENT=false

:arg-parse
if not "%1"=="" (
    if "%1"=="--rebuild" (
        set REMOVE_INTERMEDIATE=true
        set BUILD_SERVER=true
        set BUILD_CLIENT=true
    )

    if "%1"=="--server" (
        set BUILD_SERVER=true
    )

    if "%1"=="--client" (
        set BUILD_CLIENT=true
    )

    if "%1"=="--clean" (
        set REMOVE_INTERMEDIATE=true
    )

    if "%1"=="-h" (
        echo %DOC_STRING%
        echo %USAGE_STRING%
        GOTO :eof
    )

    if "%1"=="--help" (
        echo %DOC_STRING%
        echo %USAGE_STRING%
        GOTO :eof
    )

    shift
    goto :arg-parse
)

if %REMOVE_INTERMEDIATE% == false (
    if %BUILD_SERVER% == false (
        if %BUILD_CLIENT% == false (
          echo Nothing selected to be done.
          goto :eof
        )
    )
)

rem Set the visual studio solution directory
rem
set LIBCARLA_VSPROJECT_PATH=%INSTALLATION_DIR%libcarla-visualstudio

set LIBCARLA_SERVER_INSTALL_PATH=%ROOT_PATH%Unreal\CarlaUE4\Plugins\Carla\CarlaDependencies
set LIBCARLA_CLIENT_INSTALL_PATH=%ROOT_PATH%PythonAPI\dependencies

if %REMOVE_INTERMEDIATE% == true (
    echo %FILE_N% Cleaning "%LIBCARLA_SERVER_INSTALL_PATH%"
    if exist "%LIBCARLA_SERVER_INSTALL_PATH%" rmdir /S /Q "%LIBCARLA_SERVER_INSTALL_PATH%"

    echo %FILE_N% Cleaning "%LIBCARLA_CLIENT_INSTALL_PATH%"
    if exist "%LIBCARLA_CLIENT_INSTALL_PATH%" rmdir /S /Q "%LIBCARLA_CLIENT_INSTALL_PATH%"
)

if not exist "%LIBCARLA_VSPROJECT_PATH%" mkdir "%LIBCARLA_VSPROJECT_PATH%"
cd "%LIBCARLA_VSPROJECT_PATH%"

rem Build libcarla server
rem
if %BUILD_SERVER% == true (
    cmake -G "Visual Studio 15 2017 Win64" -DCMAKE_BUILD_TYPE=Server -DCMAKE_CXX_FLAGS_RELEASE="/MD /MP" -DCMAKE_INSTALL_PREFIX=%LIBCARLA_SERVER_INSTALL_PATH% %ROOT_PATH%
    if %errorlevel% neq 0 goto error_cmake

    cmake --build . --config Release --target install | findstr /V "Up-to-date:"
    if %errorlevel% neq 0 goto error_install
)

rem Build libcarla client
rem
if %BUILD_CLIENT% == true (
    cmake -G "Visual Studio 15 2017 Win64" -DCMAKE_BUILD_TYPE=Client -DCMAKE_CXX_FLAGS_RELEASE="/MD /MP" -DCMAKE_INSTALL_PREFIX=%LIBCARLA_CLIENT_INSTALL_PATH% %ROOT_PATH%
    if %errorlevel% neq 0 goto error_cmake

    cmake --build . --config Release --target install  | findstr /V "Up-to-date:"
    if %errorlevel% neq 0 goto error_install
)

goto success

rem ============================================================================
rem -- Messages and Errors -----------------------------------------------------
rem ============================================================================

:success
    if %BUILD_SERVER% == true echo %FILE_N% LibCarla server has been successfully installed in "%LIBCARLA_SERVER_INSTALL_PATH%"!
    if %BUILD_CLIENT% == true echo %FILE_N% LibCarla client has been successfully installed in "%LIBCARLA_CLIENT_INSTALL_PATH%"!
    goto good_exit

:error_cmake
    echo.
    echo %FILE_N% [ERROR] An error ocurred while executing the cmake.
    echo           [ERROR] Possible causes:
    echo           [ERROR]  - Make sure "CMake" is installed.
    echo           [ERROR]  - Make sure it is available on your Windows "path".
    echo           [ERROR]  - CMake 3.9.0 or higher is required.
    goto bad_exit

:error_install
    echo.
    echo %FILE_N% [ERROR] An error ocurred while installing using Visual Studio 15 2017 Win64.
    echo           [ERROR] Possible causes:
    echo           [ERROR]  - Make sure you have Visual Studio installed.
    echo           [ERROR]  - Make sure you have the "x64 Visual C++ Toolset" in your path.
    echo           [ERROR]    For example using the "Visual Studio x64 Native Tools Command Prompt",
    echo           [ERROR]    or the "vcvarsall.bat".
    goto bad_exit

:good_exit
    endlocal
    exit /b 0

:bad_exit
    endlocal
    exit /b %errorlevel%
