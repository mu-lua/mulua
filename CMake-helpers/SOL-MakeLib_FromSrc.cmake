function(SOL_MakeLib_FromSrc)
	# Parse parameters: <TARGET_NAME> VERSION <VERSION.MAJOR.MINOR> [HASH <DOWNLOAD_HASH>]
	set(_SOL_SYNTAX " Syntax: SOL_MakeLib_FromSrc(<TARGET_NAME> VERSION <VERSION.MAJOR[.MINOR]> [HIDE_DOWNLOAD_PROGRESS] [JOIN_HEADERS])")
	block(PROPAGATE _SOL_TARGET_NAME _SOL_VERSION _SOL_GIT_TAG _SOL_SHOW_GIT_PROGRESS _SOL_JOIN_HEADERS)
		cmake_parse_arguments(_SOL "HIDE_PROGRESS;JOIN_HEADERS" "VERSION" "" ${ARGN})
		list(LENGTH _SOL_UNPARSED_ARGUMENTS _SOL_UNPARSED_COUNT)

		# Check <TARGET_NAME> <VERSION> provided
		if(_SOL_UNPARSED_COUNT LESS 1)
			message(FUNCTION_SYNTAX ${_SOL_SYNTAX})
			message(FATAL_ERROR "You must specify the argument TARGET_NAME to the function FetchLibrary_SOL")
		endif()
		if(_SOL_UNPARSED_COUNT GREATER 1)
			message(FUNCTION_SYNTAX ${_SOL_SYNTAX})
			message(FATAL_ERROR "You have supplied too many parameters to the function FetchLibrary_SOL")
		endif()
		set(_SOL_TARGET_NAME ${_SOL_UNPARSED_ARGUMENTS})
		if(NOT _SOL_VERSION)
			set(_SOL_GIT_TAG "origin/develop")
			set(_SOL_VERSION "4.0")
		else()
			set(_SOL_GIT_TAG "v${_SOL_VERSION}")
		endif()
		set(_SOL_SHOW_GIT_PROGRESS FALSE)
		if(NOT _SOL_HIDE_PROGRESS)
			set(_SOL_SHOW_GIT_PROGRESS TRUE)
		endif()
	endblock()

	# Configure SOL-MakeLib_FromSrc.README show the set(PARENT_SCOPE) at the end of the function
	string(REPLACE ".cmake" ".README" README_FULLNAME "${CMAKE_CURRENT_FUNCTION_LIST_FILE}")
	include(ConfigureSourceFile)
	configure_source_file("${README_FULLNAME}")
	configure_source_outfilename("${README_FULLNAME}" README_GENFILE)
	# Create the READY target so we can add dependencies prior to creating the library
	set(SOL_SOURCE_FULLDIR "${CMAKE_SOURCE_DIR}/build.depends/${_SOL_TARGET_NAME}")
	add_custom_target(${_SOL_TARGET_NAME}-READY
			COMMENT ======================================================================
			COMMAND echo ${_SOL_VERSION} > "${SOL_SOURCE_FULLDIR}.version"
			COMMAND ${CMAKE_COMMAND} -E cat ${README_GENFILE}
		)

	# Check if the version has changed
	set(PREV_VERSION NO)
	if(EXISTS "${SOL_SOURCE_FULLDIR}.version")
		file(READ "${SOL_SOURCE_FULLDIR}.version" PREV_VERSION)
	endif()
	if(PREV_VESION VERSION_EQUAL _SOL_VERSION)
		message("EQUAL VERSION")
	endif()

	# Download the SOL github, if it is the wrong version or it is missing the include directory
	if((NOT PREV_VESION VERSION_EQUAL _SOL_VERSION) OR (NOT EXISTS ${CMAKE_SOURCE_DIR}/build.depends/${_SOL_TARGET_NAME}/include/sol))
		include(FetchContent)
		FetchContent_Populate(${_SOL_TARGET_NAME}
				GIT_REPOSITORY "https://github.com/ThePhD/sol2.git"
				GIT_TAG "${_SOL_GIT_TAG}"
				GIT_REMOTE_UPDATE_STRATEGY "CHECKOUT"
				GIT_SHALLOW TRUE
				GIT_PROGRESS ${_SOL_SHOW_GIT_PROGRESS}
				USES_TERMINAL_DOWNLOAD TRUE
					SOURCE_DIR "${SOL_SOURCE_FULLDIR}"
			)
		# Remove unused source and set remainder to ReadOnly
		block()
			file(REMOVE_RECURSE "${SOL_SOURCE_FULLDIR}/cmake")
			file(REMOVE_RECURSE "${SOL_SOURCE_FULLDIR}/documentation")
			file(REMOVE_RECURSE "${SOL_SOURCE_FULLDIR}/examples")
			file(REMOVE_RECURSE "${SOL_SOURCE_FULLDIR}/scripts")
			file(REMOVE_RECURSE "${SOL_SOURCE_FULLDIR}/subprojects")
			file(REMOVE_RECURSE "${SOL_SOURCE_FULLDIR}/tests")
			file(GLOB_RECURSE
					SOL_SOURCE_FILES_TO_READONLY
					"SOURCE_DIR ${SOL_SOURCE_FULLDIR}/*"
					LIST_DIRECTORIES FALSE
				)
			foreach(SOL_SOURCE_FILE ${SOL_SOURCE_FILES_TO_READONLY})
				if(EXISTS "${SOL_SOURCE_FILE}")
					file(CHMOD "${SOL_SOURCE_FILE}" FILE_PERMISSIONS WORLD_READ GROUP_READ OWNER_READ)
				endif()
			endforeach()
		endblock()
	endif()

	# Use the downloaded python script to combine the headers		
	set(INCLUDE_FULLDIR ${CMAKE_SOURCE_DIR}/build.depends/${_SOL_TARGET_NAME}/include)
	if(NOT _SOL_JOIN_HEADERS)
		set(_SOL_JOIN_HEADERS "NOT REQUESTED")
	else()
		find_package(Python3)
		if(Python3_FOUND)
			# SOL uses find_package(PythonInterp 3) -> CMP0148 updated it to find_package(Python3)
			# Combine the headers (added to the READY target)
			set(RESTORE_SUPPRESS_DEVELOPER_WARNINGS "$CACHE{CMAKE_SUPPRESS_DEVELOPER_WARNINGS}")
			set(CMAKE_SUPPRESS_DEVELOPER_WARNINGS ON CACHE INTERNAL "SUPRESS --dev WARNINGS IN LIBRARY INCLUDE" FORCE)
			add_subdirectory(${CMAKE_SOURCE_DIR}/build.depends/${_SOL_TARGET_NAME}/single EXCLUDE_FROM_ALL)
			set(CMAKE_SUPPRESS_DEVELOPER_WARNINGS ${RESTORE_SUPPRESS_DEVELOPER_WARNINGS} CACHE INTERNAL "" FORCE)

			get_property(BINARY_DIR TARGET sol2_single PROPERTY INTERFACE_INCLUDE_DIRECTORIES)
			set(INCLUDE_FULLDIR ${CMAKE_SOURCE_DIR}/build.depends/${_SOL_TARGET_NAME}/combined)
			add_custom_command(
					COMMENT "Transfer *.hpp files to ${INCLUDE_FULLDIR}"
					COMMAND ${CMAKE_COMMAND} -E make_directory "${INCLUDE_FULLDIR}/sol"
					COMMAND ${CMAKE_COMMAND} -E copy_directory "${BINARY_DIR}" "${INCLUDE_FULLDIR}"
					DEPENDS
						sol2_single_header_generator
					OUTPUT
						"${INCLUDE_FULLDIR}/sol/sol.hpp"
						"${INCLUDE_FULLDIR}/sol/forward.hpp"
						"${INCLUDE_FULLDIR}/sol/config.hpp"
				)
			add_custom_target(sol2_single_header_transfer
					DEPENDS
						"${INCLUDE_FULLDIR}/sol/sol.hpp"
						"${INCLUDE_FULLDIR}/sol/forward.hpp"
						"${INCLUDE_FULLDIR}/sol/config.hpp"
				)
			add_dependencies(${_SOL_TARGET_NAME}-READY sol2_single_header_transfer)
			set(_SOL_JOIN_HEADERS "COMBINE SUCCESSFUL")
		else()
			message("-- Could not find python to join the header files")
			set(_SOL_JOIN_HEADERS "REQUIRES PYTHON")
		endif()
	endif()

	# Create the SOL library in this project (triggers READY target)
	add_library(${_SOL_TARGET_NAME}-library INTERFACE)
	set_target_properties(${_SOL_TARGET_NAME}-library
			PROPERTIES
				IMPORTED_CONFIGURATIONS NOCONFIG
				IMPORTED_LINK_INTERFACE_LANGUAGES_NOCONFIG "CXX"
				INTERFACE_INCLUDE_DIRECTORIES "${INCLUDE_FULLDIR}"
		)
	add_dependencies(${_SOL_TARGET_NAME}-library ${_SOL_TARGET_NAME}-READY)

	# Build the library aliases
	add_library(${_SOL_TARGET_NAME}::library ALIAS ${_SOL_TARGET_NAME}-library)
	if(NOT _SOL_TARGET_NAME STREQUAL "SOL")
		add_library(SOL::library ALIAS ${_SOL_TARGET_NAME}-library)
	endif()

	# Return these variables from the function - they may be used in the parent CMake files to get information about the build
	set(${_SOL_TARGET_NAME}_FOUND TRUE PARENT_SCOPE)
	set(SOL_LOADED TRUE PARENT_SCOPE)
	set(SOL_PROJECTNAME ${_SOL_TARGET_NAME} PARENT_SCOPE)
	set(SOL_VERSION ${_SOL_VERSION} PARENT_SCOPE)
	set(SOL_JOINED_HEADERS ${_SOL_JOIN_HEADERS} PARENT_SCOPE)
endfunction()
