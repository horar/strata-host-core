cmake_minimum_required(VERSION 3.5)
project (couchbase-lite-cpp)

# Compiler details
#SET(GCC_COMPILE_FLAGS "-std=c++11")

# Compiler details from Couchbase
SET(CMAKE_CXX_FLAGS "-v -std=c++11")

# Required headers
set(CB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/couchbase-lite-core")
#if (NOT IS_DIRECTORY ${CB_DIR}/build_cmake/macos)
#
#endif ()
if(UNIX AND NOT APPLE)
set(CB_LIB_DIR "${CB_DIR}/build_cmake/unix")
message("Couchbase Library for Linux")
elseif(UNIX AND APPLE)
message("Couchbase library for MacOS")
set(CB_LIB_DIR "${CB_DIR}/build_cmake/macos")
endif()
set(SHARED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../shared")
message (${CB_LIB_DIR})
include_directories( ${CMAKE_CURRENT_SOURCE_DIR}
					"${CMAKE_CURRENT_SOURCE_DIR}/include"
					"${SHARED_DIR}/cpp-base64"				#cpp-base64 submodule
					"${SHARED_DIR}/rapidjson/include"		#rapidjson submodule
					"${CB_DIR}/C"
					"${CB_DIR}/C/include"
                    "${CB_DIR}/vendor/fleece/API"
					"${CB_DIR}/vendor/fleece/Fleece/Core"
					"${CB_DIR}/vendor/fleece/Fleece/Mutable"
					"${CB_DIR}/vendor/fleece/Fleece/Support"
					"${CB_DIR}/LiteCore/Database"
					"${CB_LIB_DIR}"
					)
link_directories(${CMAKE_CURRENT_SOURCE_DIR})

# For Windows Visual Studio, add the library folder; Assuming library is pre-compiled
if(MSVC AND CMAKE_CL_64)
	message("Compiling with Visual Studio 64bit")
	find_library(litecore STATIC
				NAME LiteCore
				HINTS "${CB_DIR}/build_cmake/x64/RelWithDebInfo")
	find_library(litecoreStatic STATIC
					NAME LiteCoreStatic
					HINTS "${CB_DIR}/build_cmake/x64/RelWithDebInfo")
	find_library(litecoreRest STATIC
					NAME LitecoreRest
					HINTS "${CB_DIR}/build_cmake/x64/RelWithDebInfo")
elseif(MSVC)
	message("Compiling with Visual Studio")
	find_library(litecore STATIC
				NAME LiteCore
				HINTS "${CB_DIR}/build_cmake/x86/RelWithDebInfo")
	find_library(litecoreStatic STATIC
					NAME LiteCoreStatic
					HINTS "${CB_DIR}/build_cmake/x86/RelWithDebInfo")
	find_library(litecoreRest STATIC
					NAME LitecoreRest
					HINTS "${CB_DIR}/build_cmake/x86/RelWithDebInfo")

else("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
	# Libraries that Nimbus requires from Couchbase
	find_library(litecore STATIC NAMES
				LiteCore
				HINTS "${CB_LIB_DIR}")
	find_library(litecoreStatic STATIC
					NAME LiteCoreStatic
					HINTS "${CB_DIR}/build_cmake/macos")
	find_library(litecoreRest STATIC
					NAME LiteCoreREST 		# Name has caps in linux
					HINTS "${CB_DIR}/build_cmake/macos")
	find_library(FleeceStatic STATIC
			NAME FleeceStatic 		# Name has caps in linux
			HINTS "${CB_DIR}/build_cmake/macos/vendor/fleece")
	# Couchbase requires this
	find_library(libdl dl)
endif()

if (litecore)
	message("Found LiteCore library(s) ${litecore}")
endif()
if (litecoreStatic)
	message("Found LiteCoreStatic library(s) ${litecoreStatic}")
endif()
if (litecoreRest)
	message("Found LiteCoreRest library(s) ${litecoreRest}")
endif()

set(LIB_SOURCES
		${CMAKE_CURRENT_SOURCE_DIR}/src/SGDatabase.cpp
		${CMAKE_CURRENT_SOURCE_DIR}/src/SGDocument.cpp
		${CMAKE_CURRENT_SOURCE_DIR}/src//SGMutableDocument.cpp)

# Make couchbase-lite-cpp a library;
add_library(couchbase-lite-cpp STATIC ${LIB_SOURCES})
# We only need litecore library linked
target_link_libraries(couchbase-lite-cpp ${litecore} ${libdl} ${FleeceStatic})

# Compile source/s
set(SOURCES ${SHARED_DIR}/cpp-base64/base64.cpp test/test.cpp)

#executable
add_executable (couchbase_lite_cpp_test ${SOURCES})
target_link_libraries(couchbase_lite_cpp_test couchbase-lite-cpp ${FleeceStatic})

#executable
add_executable (couchbase_lite_cpp_fleece_test test/fleece_test.cpp)
target_link_libraries(couchbase_lite_cpp_fleece_test ${litecore} ${libdl} ${FleeceStatic})