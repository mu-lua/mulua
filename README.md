# Multi User (Dungeon) - LUA

## Project Overview

MU-LUA is a C++ Server that provides a telnet text environment.  It is inspired on [Evennia](https://github.com/evennia/evennia) but uses the LUA language rather than python to expand the game functions.

## Run Game
### Windows
- Windows CMD
  ```bat
  winget install -e --id Git.Git
  git clone https://github.com/mu-lua/mulua.git <base_directory>
  cd <base_directory>
  make env
  make clean_all
  make server
  ```
- Start Game
  ```bat
  cd <base_directory>\src\user
  git clone https://github.com/<developer>/<gamename>.git <game_directory>
  mu-lua-srvr --run <game_directory>
  ```

### WSL - Linux on Windows
- Ubuntu 18.04 only provides libfmt.v4 (which does not include "fmt/core.h"), as well as no longer being supported by vsCode
- It is also easier to run a netwrok server on WSLv1, which connects directly to the network card, rather than using a virtual newtork bridge with a firewall.

You can get information on your current WSL environments
```bat
wsl --list --verbose
wsl -d <distro> lsb_release -a
```
Build a WSLv1 Ubuntu22 environment
```bat
wsl --install Ubuntu-24.04
wsl --set-version Ubunutu-24.04 1
```
Start your WSL environment, then follow the Linux instructions
```bat
REM long hand
wsl --distribution Ubunutu24.04

REM short hand
wsl -d Ubunutu24.04

REM Set the default so you don't have to specify the distro every time
wsl --set-default Ubunutu22.04
wsl
```
### Linux
- Linux/WSL Shell
  ```sh
  sudo apt-get install git
  git clone https://github.com/mu-lua/mulua.git <base_directory>
  cd <base_directory>
  make env
  make clean_all
  make server
  ```
- Start Game
  ```sh
  cd <base_directory>/src/user
  git clone https://github.com/<developer>/<gamename>.git <game_directory>
  mu-lua-srvr --run <game_directory>
  ```

## Develop a LUA Game

Follow the instructions to run the game.  You can use the manuals to help you design your own game by editing the LUA files in the game directory.  Each game will use its own source control and have it's own contribution rules and README.md file

## Contribute to Server, Manual & Tools

- Linux Shell (using VS Code)
  ```sh
  sudo apt-get install git
  git clone https://github.com/mu-lua/mulua.git <base_directory>
  cd <base_directory>
  make env
  make clean_all
  code .vscode/mulua.code-workspace
  ```
- Windows CMD (using Visual Studio 2022 Community - CMake Generator)
  ```bat
  git clone https://github.com/mu-lua/mulua.git <base_directory>
  cd <base_directory>

  REM First time including downloading editor
  make generate_vs2022_sln        (abbrev: make gen_sln)

  REM When CMakeLists.txt has changed
  make update_vs2022_sln          (abbrev: make open_sln)

  REM open generated solution1
  explorer build\mu-lua.sln
  ```
- Windows CMD (using Visual Studio 2022 Community - Native CMake)
  ```bat
  git clone https://github.com/mu-lua/mulua.git <base_directory>
  cd <base_directory>

  REM First time to download the editor
  make vs2022_get_editor          (abbrev: make get_vs22)

  REM To open the CMake directory in Visual Studio
  make open_vs2022_cmake          (abbrev: make open_cmake)
  ```
- Using Microsoft IDEs is just a suggestion, you can use any code editor that you are comfortable coding in. On Linux you can edit source files with NeoVIM using your own configuration without adding any files to the source tree.  You could also add instructions for your own IDE that would be a helpful contribution.
- Check the CONTRIBUTING.md file to get detailed instructions on how to upload your changes to github.com
