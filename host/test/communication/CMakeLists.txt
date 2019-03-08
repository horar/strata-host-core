project (serialtest)

# The version number
set (serialtest_VERSION_MAJOR 1)
set (serialtest_VERSION_MINOR 0)

if(WINDOWS)
SET(CMAKE_TOOLCHAIN_FILE x86_64.cmake)
SET(CMAKE_CXX_FLAGS "-v -std=gnu++11 -static-libstdc++ -static-libgcc -static")
endif()

if(LINUX)
SET(CMAKE_CXX_FLAGS "-v -std=c++11")
endif()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "Debug/")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "lib/")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "lib/")

include_directories(ArduinoJson)

set(SOURCE_HCS
   ${SOURCE}
   ${CMAKE_CURRENT_SOURCE_DIR}/serial_zmq.cpp
)

set(SOURCE_HCC
   ${SOURCE}
   ${CMAKE_CURRENT_SOURCE_DIR}/zmq_client.cpp
)

add_executable(demo_hcs ${SOURCE_HCS})
add_executable(demo_hcc ${SOURCE_HCC})

if(WINDOWS)
target_link_libraries(demo_hcs
                      -lzmq.dll
                      -lstdc++
                      -lpthread
                      -levent
                      -lserialport.dll
		                  -lws2_32
                     )
target_link_libraries(demo_hcc
                      -lzmq.dll
                      -lstdc++
                      -lpthread
                      -levent
                      -lserialport.dll
                     	-lws2_32
                      )
endif()

if(LINUX)
target_link_libraries(demo_hcs
                      -lzmq
                      -lstdc++
                      -lpthread
                      -levent
                      -lserialport
                     )
target_link_libraries(demo_hcc
                      -lzmq
                      -lstdc++
                      -lpthread
                      -levent
                      -lserialport
                      )
endif()
