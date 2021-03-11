project(strataServerSample
    VERSION 0.0.1
    LANGUAGES CXX
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

add_executable(${PROJECT_NAME}
    main.cpp
    Server.cpp
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE Qt5::Core
    PRIVATE StrataRPC-StrataServer
)

set_target_properties(${PROJECT_NAME}
    PROPERTIES AUTOMOC ON
)