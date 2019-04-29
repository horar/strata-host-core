project(connector-test
    VERSION 1.0
    LANGUAGES CXX
)

add_library( gtest UNKNOWN IMPORTED)
set_property(TARGET gtest PROPERTY IMPORTED_LOCATION "/Users/zbh8pg/ondro/projects/repository/spyglass/host/ext_libs/googletest-release-1.8.1/build/googlemock/gtest/libgtest.a")
set_property(TARGET gtest APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES "/Users/zbh8pg/ondro/projects/repository/spyglass/host/ext_libs/googletest-release-1.8.1/googletest/include/")

add_executable(connector-test
    connector-test.cpp
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE connector
    PRIVATE gtest
    pthread
)

if (WIN32)
    target_link_libraries(${PROJECT_NAME} PRIVATE Setupapi.lib Ws2_32.lib )
endif()

if (APPLE)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE ${FOUNDATION_LIBRARY} ${IOKIT_LIBRARY}
    )
endif()
