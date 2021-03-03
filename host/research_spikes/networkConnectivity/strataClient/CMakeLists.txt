project(strataClient
    DESCRIPTION "An application that acts as a physical Strata platform connected over the local network" 
    LANGUAGES CXX
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt5 COMPONENTS Core Quick REQUIRED)

add_executable(strataClient
  main.cpp
  client.cpp
  qml.qrc
)

target_compile_definitions(strataClient
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(strataClient
  PRIVATE Qt5::Core Qt5::Quick)
