@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

REM Check that we only have one target
SET /A ARGC=0    
FOR %%A in (%*) DO SET /A ARGC+=1
IF NOT !ARGC! ==1 (
  ECHO make: This version of Windows make expects one target
  EXIT /B 64
)

REM Target abbreviations
SET TARGET=%1
IF "!TARGET!" == "gen_sln" SET TARGET="generate_vs2022_sln"
IF "!TARGET!" == "open_sln" SET TARGET="update_vs2022_sln"
IF "!TARGET!" == "get_vs22" SET TARGET="vs2022_get_editor"
IF "!TARGET!" == "open_cmake" SET TARGET="open_vs2022_cmake"
REM Targets handled in the batch file
SET TARGET_PYTHON310=Y
IF "!TARGET!" == "env" SET TARGET_ENV=Y
IF "!TARGET!" == "generate_vs2022_sln" SET TARGET_GET_VS2022EDITOR=Y
IF "!TARGET!" == "generate_vs2022_sln" SET TARGET_UPDATE_OPEN_SLN=Y
IF "!TARGET!" == "update_vs2022_sln" SET TARGET_UPDATE_OPEN_SLN=Y
IF "!TARGET!" == "vs2022_get_editor" SET TARGET_GET_VS2022EDITOR=Y
IF "!TARGET!" == "open_vs2022_cmake" SET TARGET_OPEN_CMAKE_DIR=Y

REM Check that Python 3.10 is installed and at the front of the PATH variable
IF "!TARGET_PYTHON310!" == "Y" (
  SET PATH=%LOCALAPPDATA%\Programs\Python\Python310;C:\Program Files\Python310;%PATH:)=^)%
  FOR /F "usebackq tokens=2,3 delims=n." %%A IN (`PYTHON --version`) do (SET PYOLDVER=%%A.%%B)
  IF "!PYOLDVER!" == " 3.10" ECHO make: Found Python!PYOLDVER! runtime ^(required to enable SOL header unification^)
  IF NOT "!PYOLDVER!" == " 3.10" (
    SET GOTO_RETURN=RETURN_PYTHON
    GOTO SAFE_PYTHONINSTALLER_DIR
    :RETURN_PYTHON
    ECHO make: RUNNING DOWNLOAD COMMAND FOR PYTHON 3.10
    curl --location --output "!PYTHONINSTALLER!" https://www.python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe
    IF EXIST %LOCALAPPDATA%\Programs\Python\Python310 (
      ECHO:
      ECHO:
      ECHO make: ***** SELECT REPAIR OPTION *****
      "!PYTHONINSTALLER!" /simple
    ) ELSE (
      ECHO make: RUNNING INSTALL COMMAND
      "!PYTHONINSTALLER!" /simple /passive
    )
    DEL "!PYTHONINSTALLER!"
    FOR /F "usebackq tokens=*" %%A IN (`PYTHON --version`) do (SET PYNEWVER=%%A)
    ECHO make: Found Python!PYNEWVER! runtime ^(required to enable SOL header unification^)
    IF "!PYOLDVER!" == "" ECHO make: Found Python!PYNEWVER! runtime ^(required to enable SOL header unification^)
    IF NOT "!PYOLDVER!" == "" ECHO make: Found Python!PYNEWVER! runtime replacing Python!PYOLDVER! ^(required to enable SOL header unification^)
  )
  ECHO:
)

REM Search for VS2022 Build Tools
SET VS2022BE_ROOT=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\
IF EXIST !VS2022BE_ROOT! SET VS2022BE_BASE=Y
IF EXIST !VS2022BE_ROOT!VC\Auxiliary\Build\vcvarsall.bat SET VS2022BE_SETENV=Y
IF EXIST !VS2022BE_ROOT!VC\Tools\MSVC\14.39.33519\bin\Hostx64\x64\nmake.exe SET VS2022BE_NMAKE=Y
IF EXIST !VS2022BE_ROOT!Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe SET VS2022BE_CMAKE=Y
IF EXIST !VS2022BE_ROOT!VC\Tools\Llvm\x64\bin\clang.exe SET VS2022BE_CLANG=Y

REM Search for VS2022 Community Edition
SET VS2022ED_ROOT=C:\Program Files\Microsoft Visual Studio\2022\Community\
IF EXIST !VS2022ED_ROOT! SET VS2022ED_BASE=Y
IF EXIST !VS2022ED_ROOT!VC\Auxiliary\Build\vcvarsall.bat SET VS2022ED_SETENV=Y
IF EXIST !VS2022ED_ROOT!VC\Tools\MSVC\14.39.33519\bin\Hostx64\x64\nmake.exe SET VS2022ED_NMAKE=Y
IF EXIST !VS2022ED_ROOT!Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe SET VS2022ED_CMAKE=Y
IF EXIST !VS2022ED_ROOT!VC\Tools\Llvm\x64\bin\clang.exe SET VS2022ED_CLANG=Y

REM Find which version of VS2022 has the CMake and Clang components - giving priority to Build Tools
IF "!VS2022BE_BASE!!VS2022BE_SETENV!!VS2022BE_NMAKE!!VS2022BE_CMAKE!!VS2022BE_CLANG!" == "YYYYY" ECHO make: Found Visual Studio 2022 Build Enviroment ^(including CMake and Clang^)
IF "!VS2022BE_BASE!!VS2022BE_SETENV!!VS2022BE_NMAKE!!VS2022BE_CMAKE!!VS2022BE_CLANG!" == "YYYYY" SET VS_DIR=!VS2022BE_ROOT!
IF "!VS_DIR!" == "" (
  IF "!VS2022ED_BASE!!VS2022ED_SETENV!!VS2022ED_NMAKE!!VS2022ED_CMAKE!!VS2022ED_CLANG!" == "YYYYY" ECHO make: Found Visual Studio 2022 Community Edition ^(including CMake and Clang^)
  IF "!VS2022ED_BASE!!VS2022ED_SETENV!!VS2022ED_NMAKE!!VS2022ED_CMAKE!!VS2022ED_CLANG!" == "YYYYY" SET VS_DIR=!VS2022ED_ROOT!
)

REM Handle the make target ENV in this batch script
IF "!TARGET_ENV!" == "Y" (
  IF NOT "!VS_DIR!" == "" ECHO note: This cmake/compiler command line environment is ready to make this project
  IF NOT "!VS_DIR!" == "" EXIT /B 0

  REM Find a safe place to download the VS2022 installer
  SET GOTO_RETURN=RETURN_ENV
  GOTO SAFE_VSINSTALLER_DIR
  :RETURN_ENV
  REM Decide which version to update - giving priority to Build Tools
  SET VS_EDITION=vs_buildtools.exe
  IF NOT "!VS2022ED_BASE!" == "" SET VS_EDITION=vs_community.exe
  IF NOT "!VS2022BE_BASE!" == "" SET VS_EDITION=vs_buildtools.exe
  ECHO make: RUNNING DOWNLOAD COMMAND FOR VISUAL STUDIO
  curl --location --output "!VSINSTALLER!" https://aka.ms/vs/17/release/!VS_EDITION!
  ECHO make: RUNNING INSTALL COMMAND
  "!VSINSTALLER!" --add Microsoft.VisualStudio.Component.VC.CMake.Project --add Microsoft.VisualStudio.Component.VC.Llvm.Clang --add Microsoft.VisualStudio.Component.Windows10SDK.20348 --passive --wait
  SET /A ERR=%ERRORLEVEL%
  DEL "!VSINSTALLER!"
  ECHO make: !ERR!
  EXIT /B !ERR!
)

REM Download the Visual Studio 2022 Community Edition Editor
IF "!TARGET_GET_VS2022EDITOR!" == "Y" (
  REM Find a safe place to download the VS2022 installer
  SET GOTO_RETURN=RETURN_EDITOR
  GOTO SAFE_VSINSTALLER_DIR
  :RETURN_EDITOR
  REM Download Visual Studio 2022 Community Edition
  ECHO make: RUNNING DOWNLOAD COMMAND FOR VISUAL STUDIO
  curl --location --output "!VSINSTALLER!" https://aka.ms/vs/17/release/vs_community.exe
  ECHO make: RUNNING INSTALL COMMAND
  "!VSINSTALLER!" --add Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Core --add Microsoft.Component.MSBuild --add Microsoft.VisualStudio.Component.VC.CoreIde --add Microsoft.VisualStudio.Component.VC.Redist.14.Latest --add Microsoft.VisualStudio.Component.SecurityIssueAnalysis --add Microsoft.VisualStudio.Component.TextTemplating --add Microsoft.VisualStudio.Component.VC.ASAN --add Microsoft.VisualStudio.Component.CppBuildInsights --add Microsoft.VisualStudio.Component.Debugger.JustInTime --add Microsoft.VisualStudio.Component.VC.DiagnosticTools --add Microsoft.VisualStudio.Component.Graphics.Tools --add Microsoft.VisualStudio.Component.IntelliCode --add Microsoft.VisualStudio.Component.VC.CMake.Project --add Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Llvm.Clang --add Microsoft.VisualStudio.Component.VC.Llvm.ClangToolset --add Microsoft.VisualStudio.Component.VC.Llvm.Clang --add Microsoft.VisualStudio.Component.Windows10SDK.20348 --passive --wait
  SET /A ERR=%ERRORLEVEL%
  ECHO make: !ERR!
  REM Drop through if we still need to update and open the SLN
  IF NOT "!TARGET_UPDATE_OPEN_SLN!" == "Y" EXIT /B
)

IF "!VS_DIR!" == "" ECHO make: Unable to find the VisualStudio 2022 build environment
IF "!VS_DIR!" == "" ECHO note: Execute - make env
IF "!VS_DIR!" == "" EXIT /B

REM Generate cmake for VS2022, then open SLN
IF "!TARGET_UPDATE_OPEN_SLN!" == "Y" (
  PUSHD !VS_DIR!Common7\Tools
  CALL VsDevCmd.bat
  POPD
  PUSHD "%~dp0"
  IF NOT EXIST build\mu-lua.sln nmake clean_all
  cmake --preset=vs2022
  IF EXIST build\mu-lua.sln (
    ECHO make: Opening Visual Studio Solution
    EXPLORER build\mu-lua.sln
    SET /A ERR=%ERRORLEVEL%
    ECHO make: !ERR!
  )
  POPD
  EXIT /B
)
REM Open Visual Studio with the CMake directory
IF "!TARGET_OPEN_CMAKE_DIR!" == "Y" GOTO (
  PUSHD !VS_DIR!Common7\Tools
  CALL VsDevCmd.bat
  POPD
  PUSHD "%~dp0"
  RENAME CMakePresets.json CMakePresets.vscache
  ECHO Waiting for Visual Studio to close before restoring CMakePresets
  START /WAIT /B DEVENV.EXE .
  RENAME CMakePresets.vscache CMakePresets.json
  POPD
  EXIT /B
)


REM Include the Visual Studio Command Line environment
IF NOT "%VCToolsInstallDir%" == "!VS_DIR!VC\Tools\MSVC\14.39.33519\" (
  PUSHD !VS_DIR!VC\Auxiliary\Build
  IF NOT EXIST vcvarsall.bat (
    ECHO make: Unable to find the VisualStudio 2022 SDK build environment
    EXIT /B
  )
  ECHO make: Calling VCVARSALL.BAT
  CALL vcvarsall.bat x64
  POPD
)

REM Finally run NMAKE with the target
PUSHD "%~dp0"
ECHO make: Running NMAKE !TARGET!
nmake !TARGET!
SET ERR=%ERRORLEVEL%
ECHO make: !ERR!
POPD
EXIT /B 0



:SAFE_VSINSTALLER_DIR
  SET VSINSTALLER=
  IF NOT "%TMP%"=="" SET VSINSTALLER=%TMP%\vs_install.exe
  IF NOT "%TEMP%"=="" SET VSINSTALLER=%TEMP%\vs_install.exe
  IF "!VSINSTALLER!"=="" (
    MKDIR "%~dp0.vstudio2022"
    SET VSINSTALLER=%~dp0.personal\vs_install.exe
  )
  GOTO !GOTO_RETURN!

:SAFE_PYTHONINSTALLER_DIR
  SET PYTHONINSTALLER=
  IF NOT "%TMP%"=="" SET PYTHONINSTALLER=%TMP%\python_install.exe
  IF NOT "%TEMP%"=="" SET PYTHONINSTALLER=%TEMP%\python_install.exe
  IF "!PYTHONINSTALLER!"=="" (
    MKDIR "%~dp0.vstudio2022"
    SET PYTHONINSTALLER=%~dp0.personal\python_install.exe
  )
  GOTO !GOTO_RETURN!
