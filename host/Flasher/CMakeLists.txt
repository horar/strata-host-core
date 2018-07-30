cmake_minimum_required (VERSION 2.8)

project (flasher)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

#Set Path
set(HOST_PATH "${CMAKE_CURRENT_SOURCE_DIR}/..")
set(HCS2_PATH "${HOST_PATH}/hcs2")
set(SHARED_DIR "${HOST_PATH}/../shared")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "lib/")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "lib/")


add_subdirectory("${HCS2_PATH}/connector" ${CMAKE_CURRENT_BINARY_DIR}/connector)

include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}/include
  ${HCS2_PATH}/connector/include
  ${HCS2_PATH}/include
  ${SHARED_DIR}/bootloader/include
)

set(SOURCE
    ${SOURCE}
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Flasher.cpp
    ${SHARED_DIR}/bootloader/src/util.cpp
)

if (CROSSCOMPILE)
    message("Building WINDOWS booo...")
elseif (UNIX AND NOT APPLE AND NOT CROSSCOMPILE)
    message("Building LINUX yea...")
elseif (APPLE)
    message("Building MAC yea...")
else()
    message("ERROR: unsupported operating system !")
endif ()

if (CROSSCOMPILE)
    message("TOOL CHAIN: windows")
    SET(CMAKE_TOOLCHAIN_FILE ./cmake/x86_64.cmake)
    SET(CMAKE_CXX_FLAGS "-v -std=gnu++11 -static-libstdc++ -static-libgcc -static -mno-ms-bitfields")
elseif(UNIX AND NOT APPLE AND NOT CROSSCOMPILE)
    message("TOOL CHAIN: linux")
    SET(CMAKE_CXX_FLAGS "-v -std=c++11")
    set(CMAKE_BUILD_TYPE Debug)
elseif (APPLE)
    message("TOOL CHAIN: mac")
    SET(CMAKE_CXX_FLAGS "-v -std=c++11")
    set(CMAKE_BUILD_TYPE Debug)
    # To enable debugging
    set(CMAKE_BUILD_TYPE RelWithDebInfo)
    find_library(IOKIT_LIBRARY IOKit)
    find_library(FOUNDATION_LIBRARY Foundation)
else()
    message("ERROR: unsupported operating system !")
endif ()

if (CROSSCOMPILE)
    # --- WINDOWS
    message("INCLUDE/LITECORE: windows")

    # LibEvent
    link_directories(${HOST_PATH}/lib/cross-lib/bin)
    link_directories(${HOST_PATH}/lib/cross-lib/lib)
    include_directories(${HOST_PATH}/lib/cross-lib/include)
    include_directories(${SHARED_DIR}/rapidjson/include)

    # ZMQ
    link_directories(${HOST_PATH}/lib/windows/zeromq)

elseif (UNIX AND NOT APPLE AND NOT CROSSCOMPILE)
    #--- LINUX
    message("INCLUDE/LITECORE: linux")
    include_directories(${HOST_PATH}/lib/linux/include)
    include_directories(${SHARED_DIR}/rapidjson/include)
    link_directories(${HOST_PATH}/lib/linux/lib)

elseif (APPLE)
    #--- Mac OSX
    message("INCLUDE/LITECORE: mac")

    # Include Files
    include_directories(${HOST_PATH}/include/macos/libserial)
    include_directories(${HOST_PATH}/include/macos/libzmq)
    include_directories(${HOST_PATH}/include)
    # include_directories(${HCS2_PATH}/include)
    include_directories(${SHARED_DIR}/rapidjson/include)
    # Target Files
    link_directories(${HOST_PATH}/lib/macos/libserial)
    link_directories(${HOST_PATH}/lib/macos/libzmq)

else()
    message("ERROR: unsupported operating system !")
endif ()


add_library(${PROJECT_NAME} ${SOURCE})

if (CROSSCOMPILE)
    message("LINKING: windows")
    target_link_libraries(${PROJECT_NAME}
            -lzmq.dll
            -lstdc++
            -lpthread
            -lserialport.dll
            -lws2_32
            connector
            )
elseif( UNIX AND NOT APPLE AND NOT CROSSCOMPILE)
    message("LINKING: linux")
    target_link_libraries(${PROJECT_NAME}
            -lzmq
            -lstdc++
            -lpthread
            -lserialport
            connector
            )
elseif (APPLE)
    message("LINKING: mac")
    target_link_libraries(${PROJECT_NAME}
            -lzmq
            -lstdc++
            -lpthread
            -lserialport
            ${FOUNDATION_LIBRARY} ${IOKIT_LIBRARY}
            connector
            )

else()
    message("ERROR: unsupported operating system !")
endif ()

target_include_directories (${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

add_subdirectory(flasher-cli)
add_subdirectory(test)
