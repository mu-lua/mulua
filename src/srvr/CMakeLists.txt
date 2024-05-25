cmake_minimum_required(VERSION 3.25)

add_executable(mu-lua-srvr)
set_property(TARGET mu-lua-srvr PROPERTY RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/../user")
set_property(TARGET mu-lua-srvr PROPERTY CXX_STANDARD 23)
set_property(TARGET mu-lua-srvr PROPERTY CXX_STANDARD_REQUIRED ON)
set_property(TARGET mu-lua-srvr PROPERTY CXX_EXTENSIONS OFF)

include(CheckCXXCompilerFlag)
if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
	# set(CMAKE_REQUIRED_QUIET TRUE)
	# check_cxx_compiler_flag(-Werror GNU_WARN_AS_ERRORS)
	target_compile_options(mu-lua-srvr PRIVATE -Wall -Wextra -Wpedantic)
	target_compile_options(mu-lua-srvr PRIVATE -Wno-pre-c++20-compat -Wno-c++98-compat)
	
	check_cxx_compiler_flag(-fexperimental-library CLANG_EXPERIMENTAL)
	if(CLANG_EXPERIMENTAL)
		target_compile_options(mu-lua-srvr PRIVATE -fexperimental-library)
	endif()
endif()

# Use libfmt if std::format and std::print are not avaiable
include(CheckIncludeFileCXX)
check_include_file_cxx("format" CXX_STL_FORMAT_AVAILABLE)
check_include_file_cxx("print" CXX_STL_PRINT_AVAILABLE)
if (NOT (CXX_STL_FORMAT_AVAILABLE AND CXX_STL_PRINT_AVAILABLE))
	SET(CMAKE_FIND_PACKAGE_SORT_ORDER NATURAL)
	SET(CMAKE_FIND_PACKAGE_SORT_DIRECTION DEC)
	find_package(fmt 5 REQUIRED)
	target_include_directories(mu-lua-srvr PRIVATE "libfmt_polyfill")
	file(GLOB POLYFILL_FILES "libfmt_polyfill/*")
	target_sources(mu-lua-srvr PRIVATE FILE_SET polyfill_fmt TYPE HEADERS FILES ${POLYFILL_FILES})
	target_link_libraries(mu-lua-srvr fmt::fmt)
endif()

# This executable uses the libraries: SOL & LUA
target_link_libraries(mu-lua-srvr LUA::library)
target_link_libraries(mu-lua-srvr SOL::library)

# Create the version header file
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/CMake-helpers")
include(ConfigureSourceFile)
configure_source_file("${CMAKE_CURRENT_SOURCE_DIR}/include/version.cmake-in.h")
target_sources(mu-lua-srvr PRIVATE FILE_SET configured_version_file TYPE HEADERS FILES  "include/version.cmake-in.h" "include/version.cmake-out.h")

# Add the include headers to the executable
target_include_directories(mu-lua-srvr PRIVATE "include")
target_sources(mu-lua-srvr PRIVATE FILE_SET cpp_headers TYPE HEADERS FILES "include/mulua-types.h")
target_sources(mu-lua-srvr PRIVATE FILE_SET sol_inline TYPE HEADERS FILES "include/sol-nowarnings.h")
target_sources(mu-lua-srvr PRIVATE "main.cpp")
