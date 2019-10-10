project(0_mq_training
    LANGUAGES CXX
)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "../bin/")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "../lib/")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "../lib/")
set(CMAKE_BUILD_TYPE Debug)

if(0)
	set(CMAKE_CXX_FLAGS "-g -Os -fdata-sections -ffunction-sections -Wl,--gc-sections -Wl,--strip-all  -fno-threadsafe-statics -levent -levent_core ")
	add_compile_options(-std=c++11)
endif(1)

include_directories(lib)
add_executable(client_cli src/client_cli.cpp)

target_link_libraries(client_cli
-levent_core
-lzmq
)
