cmake_minimum_required(VERSION 3.5)

project (couchbase-lite-cpp)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(couchbase-lite-core)

set(CB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/couchbase-lite-core")

add_library(${PROJECT_NAME}
	${CMAKE_CURRENT_SOURCE_DIR}/src/SGDatabase.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/SGDocument.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/SGMutableDocument.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/SGReplicator.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/SGReplicatorConfiguration.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/SGURLEndpoint.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/SGBasicAuthenticator.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/SGUtility.cpp
	#HACK: This is not included in couchbase-lite-core. But, we need it for the replicator
	${CB_DIR}/Replicator/CivetWebSocket.cc
)

target_include_directories(${PROJECT_NAME}
	PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include"
	PUBLIC "${CB_DIR}/C/Include"
	PUBLIC "${CB_DIR}/vendor/fleece/API"
	PUBLIC "${CB_DIR}/vendor/fleece/Fleece/Core"
	PUBLIC "${CB_DIR}/vendor/fleece/Fleece/Mutable"
	PUBLIC "${CB_DIR}/vendor/fleece/Fleece/Support"
	PRIVATE "${CB_DIR}/Replicator"
	PRIVATE "${CB_DIR}/LiteCore/Support"
	PRIVATE "${CB_DIR}/vendor/BLIP-Cpp/include/blip_cpp"
	PRIVATE "${CB_DIR}/vendor/BLIP-Cpp/src/util"
	PRIVATE "${CB_DIR}/vendor/civetweb/include"
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE LiteCore
    PRIVATE FleeceStatic
    PRIVATE CivetWeb
    PRIVATE BLIPStatic
    PRIVATE Support
)

add_subdirectory(examples)
