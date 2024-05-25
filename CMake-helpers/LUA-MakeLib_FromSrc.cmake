option(USE_MAKEFILE "Use repo 'make Makefile' rather than creating CMake files (only available on Linux)" FALSE)

function(LUA_MakeLib_FromSrc)
	# Parse parameters: <TARGET_NAME> VERSION <VERSION.MAJOR.MINOR> [HASH <DOWNLOAD_HASH>]
	set(_LUA_SYNTAX " Syntax: LUA_MakeLib_FromSrc(<TARGET_NAME> VERSION <VERSION.MAJOR[.MINOR]> [HASH <DOWNLOAD_HASH>] [HIDE_DOWNLOAD_PROGRESS] [MAKE_BINARIES])")
	block(PROPAGATE _LUA_TARGET_NAME _LUA_VERSION _LUA_HASH _LUA_HIDE_DOWNLOAD_PROGRESS _LUA_MAKE_BINARIES)
		cmake_parse_arguments(_LUA "HIDE_PROGRESS;MAKE_BINARIES" "VERSION;HASH" "" ${ARGN})
		list(LENGTH _LUA_UNPARSED_ARGUMENTS _LUA_UNPARSED_COUNT)

		# Check <TARGET_NAME> <VERSION> provided
		if(_LUA_UNPARSED_COUNT LESS 1)
			message(FUNCTION_SYNTAX ${_LUA_SYNTAX})
			message(FATAL_ERROR "You must specify the argument TARGET_NAME to the function FetchLibrary_LUA")
		endif()
		if(_LUA_UNPARSED_COUNT GREATER 1)
			message(FUNCTION_SYNTAX ${_LUA_SYNTAX})
			message(FATAL_ERROR "You have supplied too many parameters to the function FetchLibrary_LUA")
		endif()
		set(_LUA_TARGET_NAME ${_LUA_UNPARSED_ARGUMENTS})
		if(NOT _LUA_VERSION)
			message(FUNCTION_SYNTAX ${_LUA_SYNTAX})
			message(FATAL_ERROR "You must specify the argument VERSION to the function FetchLibrary_LUA")
		endif()
		set(_LUA_HIDE_DOWNLOAD_PROGRESS ${_LUA_HIDE_PROGRESS})

		# Normalize the version number and provide some well known hashes
		if(_LUA_VERSION MATCHES "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$") # X.X.X
			if(NOT ${CMAKE_MATCH_1} EQUAL 5)
				message(FUNCTION_SYNTAX ${_LUA_SYNTAX})
				message(FATAL_ERROR "Expected VERSION to start wwith '5.' in the function FetchLibrary_LUA")
			endif()
		elseif(_LUA_VERSION MATCHES "([0-9]+)\\.([0-9]+)") # X.X
			if(NOT ${CMAKE_MATCH_1} EQUAL 5)
				message(FUNCTION_SYNTAX ${_LUA_SYNTAX})
				message(FATAL_ERROR "Expected VERSION to start wwith '5.' in the function FetchLibrary_LUA")
			else()
				if (${CMAKE_MATCH_2} EQUAL 0)
					set(_LUA_VERSION "5.0.3")
				elseif (${CMAKE_MATCH_2} EQUAL 1)
					set(_LUA_VERSION "5.1.5")
				elseif (${CMAKE_MATCH_2} EQUAL 2)
					set(_LUA_VERSION "5.2.4")
				elseif (${CMAKE_MATCH_2} EQUAL 3)
					set(_LUA_VERSION "5.3.6")
				elseif (${CMAKE_MATCH_2} EQUAL 4)
					set(_LUA_VERSION "5.4.6")
				else()			
					set(_LUA_VERSION 5.${CMAKE_MATCH_2}.0) # 5.5+.0
				endif()
			endif()
		else()
			message(FUNCTION_SYNTAX ${_LUA_SYNTAX})
			message(FATAL_ERROR "Cannot deduce the proper Lua version from ${_LUA_VERSION}")
		endif()

		# Lookup hash values for known versions
		block(PROPAGATE _LUA_VERSION _LUA_HASH)
			if(${_LUA_VERSION} STREQUAL "5.4.6")
				set(_LUA_HASH "SHA256=7d5ea1b9cb6aa0b59ca3dde1c6adcb57ef83a1ba8e5432c0ecd06bf439b3ad88")
			elseif(${_LUA_VERSION} STREQUAL "5.4.5")
				set(_LUA_HASH "SHA256=59df426a3d50ea535a460a452315c4c0d4e1121ba72ff0bdde58c2ef31d6f444")
			elseif(${_LUA_VERSION} STREQUAL "5.4.4")
				set(_LUA_HASH "SHA256=164c7849653b80ae67bec4b7473b884bf5cc8d2dca05653475ec2ed27b9ebf61")
			elseif(${_LUA_VERSION} STREQUAL "5.4.3")
				set(_LUA_HASH "SHA256=f8612276169e3bfcbcfb8f226195bfc6e466fe13042f1076cbde92b7ec96bbfb")
			elseif(${_LUA_VERSION} STREQUAL "5.4.2")
				set(_LUA_HASH "SHA256=11570d97e9d7303c0a59567ed1ac7c648340cd0db10d5fd594c09223ef2f524f")
			elseif(${_LUA_VERSION} STREQUAL "5.4.1")
				set(_LUA_HASH "SHA256=4ba786c3705eb9db6567af29c91a01b81f1c0ac3124fdbf6cd94bdd9e53cca7d")
			elseif(${_LUA_VERSION} STREQUAL "5.4.0")
				set(_LUA_HASH "SHA256=eac0836eb7219e421a96b7ee3692b93f0629e4cdb0c788432e3d10ce9ed47e28")
			elseif(${_LUA_VERSION} STREQUAL "5.3.6")
				set(_LUA_HASH "SHA256=fc5fd69bb8736323f026672b1b7235da613d7177e72558893a0bdcd320466d60")
			elseif(${_LUA_VERSION} STREQUAL "5.3.5")
				set(_LUA_HASH "SHA256=0c2eed3f960446e1a3e4b9a1ca2f3ff893b6ce41942cf54d5dd59ab4b3b058ac")
			elseif(${_LUA_VERSION} STREQUAL "5.3.4")
				set(_LUA_HASH "SHA256=f681aa518233bc407e23acf0f5887c884f17436f000d453b2491a9f11a52400c")
			elseif(${_LUA_VERSION} STREQUAL "5.3.3")
				set(_LUA_HASH "SHA256=5113c06884f7de453ce57702abaac1d618307f33f6789fa870e87a59d772aca2")
			elseif(${_LUA_VERSION} STREQUAL "5.3.2")
				set(_LUA_HASH "SHA256=c740c7bb23a936944e1cc63b7c3c5351a8976d7867c5252c8854f7b2af9da68f")
			elseif(${_LUA_VERSION} STREQUAL "5.3.1")
				set(_LUA_HASH "SHA256=072767aad6cc2e62044a66e8562f51770d941e972dc1e4068ba719cd8bffac17")
			elseif(${_LUA_VERSION} STREQUAL "5.3.0")
				set(_LUA_HASH "SHA256=ae4a5eb2d660515eb191bfe3e061f2b8ffe94dce73d32cfd0de090ddcc0ddb01")
			elseif(${_LUA_VERSION} STREQUAL "5.2.4")
				set(_LUA_HASH "SHA256=b9e2e4aad6789b3b63a056d442f7b39f0ecfca3ae0f1fc0ae4e9614401b69f4b")
			elseif(${_LUA_VERSION} STREQUAL "5.2.3")
				set(_LUA_HASH "SHA256=13c2fb97961381f7d06d5b5cea55b743c163800896fd5c5e2356201d3619002d")
			elseif(${_LUA_VERSION} STREQUAL "5.2.2")
				set(_LUA_HASH "SHA256=3fd67de3f5ed133bf312906082fa524545c6b9e1b952e8215ffbd27113f49f00")
			elseif(${_LUA_VERSION} STREQUAL "5.2.1")
				set(_LUA_HASH "SHA256=64304da87976133196f9e4c15250b70f444467b6ed80d7cfd7b3b982b5177be5")
			elseif(${_LUA_VERSION} STREQUAL "5.2.0")
				set(_LUA_HASH "SHA256=cabe379465aa8e388988073d59b69e76ba0025429d2c1da80821a252cdf6be0d")
			elseif(${_LUA_VERSION} STREQUAL "5.1.5")
				set(_LUA_HASH "SHA256=2640fc56a795f29d28ef15e13c34a47e223960b0240e8cb0a82d9b0738695333")
			elseif(${_LUA_VERSION} STREQUAL "5.1.4")
				set(_LUA_HASH "SHA256=b038e225eaf2a5b57c9bcc35cd13aa8c6c8288ef493d52970c9545074098af3a")
			elseif(${_LUA_VERSION} STREQUAL "5.1.3")
				set(_LUA_HASH "SHA256=6b5df2edaa5e02bf1a2d85e1442b2e329493b30b0c0780f77199d24f087d296d")
			elseif(${_LUA_VERSION} STREQUAL "5.1.2")
				set(_LUA_HASH "SHA256=5cf098c6fe68d3d2d9221904f1017ff0286e4a9cc166a1452a456df9b88b3d9e")
			elseif(${_LUA_VERSION} STREQUAL "5.1.1")
				set(_LUA_HASH "SHA256=c5daeed0a75d8e4dd2328b7c7a69888247868154acbda69110e97d4a6e17d1f0")
			elseif(${_LUA_VERSION} STREQUAL "5.1.0")
				set(_LUA_HASH "SHA256=7f5bb9061eb3b9ba1e406a5aa68001a66cb82bac95748839dc02dd10048472c1")
				set(_LUA_VERSION "5.1")
			elseif(${_LUA_VERSION} STREQUAL "5.0.3")
				set(_LUA_HASH "SHA256=1193a61b0e08acaa6eee0eecf29709179ee49c71baebc59b682a25c3b5a45671")
			elseif(${_LUA_VERSION} STREQUAL "5.0.2")
				set(_LUA_HASH "SHA256=a6c85d85f912e1c321723084389d63dee7660b81b8292452b190ea7190dd73bc")
			elseif(${_LUA_VERSION} STREQUAL "5.0.1")
				set(_LUA_HASH "SHA256=7a09d0e70dcaff7feae97cf9c154da05b1e5b92eaea2df7150b54bcaf8f3b9c6")
			elseif(${_LUA_VERSION} STREQUAL "5.0.0")
				set(_LUA_HASH "SHA256=4a23b3bcb812538c653033cd39fe9c9bd8030286b945c56eff280d452e4e244e")
				set(_LUA_VERSION "5.0")
			endif()
		endblock()

		# Check <DOWNLOAD_HASH> provided or found in previous block
		if(NOT _LUA_HASH)
			message(FUNCTION_SYNTAX ${_LUA_SYNTAX})
			message(FATAL_ERROR "Unable to lookup the HASH argument for the VERSION specefied, you need to specify HASH to the function FetchLibrary_LUA")
		endif()
	endblock()

	# Configure LUA-MakeLib_FromSrc.README show the set(PARENT_SCOPE) at the end of the function
	string(REPLACE ".cmake" ".README" README_FULLNAME "${CMAKE_CURRENT_FUNCTION_LIST_FILE}")
	include(ConfigureSourceFile)
	configure_source_file("${README_FULLNAME}")
	configure_source_outfilename("${README_FULLNAME}" README_GENFILE)

	set(LUA_SOURCE_FULLDIR "${CMAKE_SOURCE_DIR}/build.depends/${_LUA_TARGET_NAME}")

	# Build project (WIN32 create a CMake build, LINUX use make install)
	if(LINUX AND USE_MAKEFILE)
		if(${_LUA_MAKE_BINARIES})
			set(_LUA_MAKE make linux)
			set(_LUA_INSTALL sudo make install)
		else()
			set(_LUA_MAKE make linux ALL=liblua.a)
			set(_LUA_INSTALL sudo make install "INSTALL_EXEC=echo -- Skipping binary installation...")
		endif()
		list(APPEND _LUA_BUILD_COMMANDS "${_LUA_MAKE}" "${_LUA_INSTALL}")

		include(ExternalProject)
		ExternalProject_Add(${_LUA_TARGET_NAME}-make
				URL "https://www.lua.org/ftp/lua-${_LUA_VERSION}.tar.gz"
				URL_HASH ${_LUA_HASH}
				DOWNLOAD_NO_PROGRESS ${_LUA_HIDE_DOWNLOAD_PROGRESS}
					SOURCE_DIR "${LUA_SOURCE_FULLDIR}/repo"
					BUILD_IN_SOURCE ON
						CONFIGURE_COMMAND ""
						BUILD_COMMAND ${_LUA_MAKE}
						INSTALL_COMMAND ${_LUA_INSTALL}
			)

		# Use the READY custom target to link the output from the external project and (the library definition)
		add_custom_target(${_LUA_TARGET_NAME}-READY
				COMMENT ======================================================================
				COMMAND echo ${_LUA_VERSION} > "${LUA_SOURCE_FULLDIR}.version"
				COMMAND ${CMAKE_COMMAND} -E cat ${README_GENFILE}
				DEPENDS
					${_LUA_TARGET_NAME}-make
				BYPRODUCTS
					"/usr/include/sol/sol.hpp"
					"/usr/local/lib/liblua.a"
			)

		# Import the 'make install' LUA library into this project
		add_library(${_LUA_TARGET_NAME}-library STATIC IMPORTED)
		set_target_properties(${_LUA_TARGET_NAME}-library PROPERTIES
				INTERFACE_INCLUDE_DIRECTORIES "/usr/include"
				IMPORTED_CONFIGURATIONS NOCONFIG
				IMPORTED_LINK_INTERFACE_LANGUAGES_NOCONFIG "C"
				IMPORTED_LOCATION_NOCONFIG
					"/usr/local/lib/liblua.a"
			)
	else()
		list(APPEND _LUA_BUILD_COMMANDS
				"cmake -S <repo_directory> -B <build_directory>"
				"cmake --build <build_directory>"
			)

		# Generate our CMakeLists.txt file, download LUA and patch in the generate file
		include(ConfigureSourceFile)
		configure_source_file("${CMAKE_MODULE_PATH}/LUA-root-CMakeLists.txt")
		configure_source_outfilename("${CMAKE_MODULE_PATH}/LUA-root-CMakeLists.txt" GEN_CMAKELISTS)
		include(FetchContent)
		FetchContent_Declare(${_LUA_TARGET_NAME}-library
			EXCLUDE_FROM_ALL
			URL "https://www.lua.org/ftp/lua-${_LUA_VERSION}.tar.gz"
			URL_HASH ${_LUA_HASH}
			DOWNLOAD_NO_PROGRESS ${_LUA_HIDE_DOWNLOAD_PROGRESS}
			DOWNLOAD_EXTRACT_TIMESTAMP TRUE
			USES_TERMINAL_DOWNLOAD TRUE
				SOURCE_DIR ${LUA_SOURCE_FULLDIR}/repo
					PATCH_COMMAND ${CMAKE_COMMAND} -E copy ${GEN_CMAKELISTS} CMakeLists.txt
		)
		# Update the "${LUA_SOURCE_FULLDIR}/repo/CMakeLists.txt" if it has changed
		if(EXISTS "${LUA_SOURCE_FULLDIR}/repo")
			configure_file("${GEN_CMAKELISTS}" "${LUA_SOURCE_FULLDIR}/repo/CMakeLists.txt" COPYONLY)
		endif()
		# Build the library during the CONFIGURE phase
		FetchContent_MakeAvailable(${_LUA_TARGET_NAME}-library)
		# include(${LUA_SOURCE_FULLDIR}/libs/lua54-library-export.cmake)

		# Use the READY custom target to link the output from the external project and (the library definition)
		add_custom_target(${_LUA_TARGET_NAME}-READY
				COMMENT ======================================================================
				COMMAND echo ${_LUA_VERSION} > "${LUA_SOURCE_FULLDIR}.version"
				COMMAND ${CMAKE_COMMAND} -E cat ${README_GENFILE}
				SOURCES
					"${LUA_SOURCE_FULLDIR}/include/lua.hpp"
			)
	endif()
	# Use the READY custom target to link (the output from the external project) and the library definition
	add_dependencies(${_LUA_TARGET_NAME}-library ${_LUA_TARGET_NAME}-READY)

	# Build the library aliases
	add_library(${_LUA_TARGET_NAME}::library ALIAS ${_LUA_TARGET_NAME}-library)
	if(NOT _LUA_TARGET_NAME STREQUAL "LUA")
		add_library(LUA::library ALIAS ${_LUA_TARGET_NAME}-library)
	endif()

	# Return these variables from the function - they may be used in the parent CMake files to get information about the build
	set(${_LUA_TARGET_NAME}_FOUND TRUE PARENT_SCOPE)
	set(LUA_LOADED TRUE PARENT_SCOPE)
	set(LUA_PROJECTNAME ${_LUA_TARGET_NAME} PARENT_SCOPE)
	set(LUA_VERSION ${_LUA_VERSION} PARENT_SCOPE)
	set(LUA_BUILD_COMMANDS ${_LUA_BUILD_COMMANDS} PARENT_SCOPE)
endfunction()
