project (couchbase-lite-cpp
    LANGUAGES CXX
)

add_subdirectory(couchbase-lite-core)

set(CB_DIR "couchbase-lite-core")

add_library(${PROJECT_NAME}
	src/SGDatabase.cpp
	src/SGDocument.cpp
	src/SGMutableDocument.cpp
	src/SGReplicator.cpp
	src/SGReplicatorConfiguration.cpp
	src/SGURLEndpoint.cpp
	src/SGBasicAuthenticator.cpp
	src/SGUtility.cpp
	#HACK: This is not included in couchbase-lite-core. But, we need it for the replicator
	${CB_DIR}/Replicator/CivetWebSocket.cc
)

target_include_directories(${PROJECT_NAME}
	PUBLIC "include"
	PUBLIC "${CB_DIR}/C/include"
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
	PUBLIC FleeceStatic
	PRIVATE CivetWeb
	PRIVATE BLIPStatic
	PRIVATE Support
)

add_subdirectory(examples)
