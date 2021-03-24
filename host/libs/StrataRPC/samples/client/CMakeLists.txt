project(strataRPC-ClientSample
    VERSION 0.0.1
    LANGUAGES CXX
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

add_executable(${PROJECT_NAME}
    main.cpp
    Client.cpp
    logging/LoggingQtCategories.cpp
    qml.qrc
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Quick Widgets
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE Qt5::Core
    PRIVATE Qt5::Quick
    PRIVATE Qt5::Widgets
    PRIVATE StrataRPC-StrataClient
)

set_target_properties(${PROJECT_NAME} PROPERTIES
  AUTOMOC ON
  AUTORCC ON
)