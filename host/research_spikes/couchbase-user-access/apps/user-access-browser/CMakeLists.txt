project(user-access-browser
    LANGUAGES CXX
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Quick Qml Gui Widgets
    REQUIRED
)

add_executable(user-access-browser
    main.cpp
    UserAccessBrowser.h
    UserAccessBrowser.cpp

    qml.qrc
)

target_link_libraries(user-access-browser
    PUBLIC

    Qt5::Core
    Qt5::Qml
    Qt5::Gui
    Qt5::Widgets

    Database
)
