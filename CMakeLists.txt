cmake_minimum_required(VERSION 3.25)
# 3.28: C++20 modules added
# 3.27: Interactive Debugging added
# 3.26: copy_directory_if_different, file(COPY_FILE ... INPUT_MAY_BE_RECENT)
# 3.25: block command
# 3.21: VS2022 Generator

include(CMakePrintHelpers)  # provide cmake_print_variables(...)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_SCAN_FOR_MODULES OFF)

project(mu-lua
		VERSION 0.0.1.0
		DESCRIPTION "C++ MUD/MU*-LUA core development system - Add your functionality with LUA"
		HOMEPAGE_URL "https://github.com/mu-lua"
		LANGUAGES CXX
	)
# cmake_print_variables(CMAKE_CXX_COMPILE_FEATURES)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/CMake-helpers")
include(LUA-MakeLib_FromSrc)
LUA_MakeLib_FromSrc(lua5
		VERSION 5.1
		##TODO HIDE_PROGRESS
		MAKE_BINARIES
	)
cmake_print_variables(lua5_FOUND LUA_LOADED LUA_PROJECTNAME LUA_VERSION)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/CMake-helpers")
include(SOL-MakeLib_FromSrc)
SOL_MakeLib_FromSrc(sol2
		VERSION 3.3.1
		##TODO HIDE_PROGRESS
		JOIN_HEADERS
	)
cmake_print_variables(sol2_FOUND SOL_LOADED SOL_PROJECTNAME SOL_VERSION SOL_JOINED_HEADERS)

add_subdirectory(src/srvr)
