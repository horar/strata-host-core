project(StrataRPC-benchmark LANGUAGES CXX)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Test
    REQUIRED
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

add_executable(${PROJECT_NAME}
    StrataServerBenchmark.cpp
    StrataClientBenchmark.cpp
    main.cpp
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE Qt5::Test
    PRIVATE StrataRPC-StrataServer
    PRIVATE StrataRPC-StrataClient
)

add_test(NAME ${PROJECT_NAME}
    COMMAND ${PROJECT_NAME}
)

set_target_properties(${PROJECT_NAME}
    PROPERTIES AUTOMOC ON
)
