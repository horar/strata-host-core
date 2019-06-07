project(flasher
    VERSION 1.0
    LANGUAGES CXX
)

add_library(${PROJECT_NAME}
    src/Flasher.cpp
)

#target_link_libraries(${PROJECT_NAME} PRIVATE
#    RapidJSON::RapidJSON
#    PlatformManager
#    base64
#    crc16
#)

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE PlatformManager base64 crc16
)
