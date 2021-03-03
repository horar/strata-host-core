project(strataServer
    DESCRIPTION "An application that acts like Strata Host that connects to Strata platform over the local network"    
    LANGUAGES CXX
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt5 COMPONENTS Core Quick REQUIRED)

add_executable(strataServer
      main.cpp
      server.cpp
      qml.qrc
)

target_compile_definitions(strataServer
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(strataServer
  PRIVATE Qt5::Core Qt5::Quick)
