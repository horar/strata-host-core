project(strataServer
  DESCRIPTION "An application that acts like Strata Host that connects to Strata platform over the local network"    
  LANGUAGES CXX
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 COMPONENTS Core Quick REQUIRED)

add_executable(${PROJECT_NAME}
  main.cpp
  server.cpp
  qml.qrc
)

target_compile_definitions(${PROJECT_NAME}
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(${PROJECT_NAME}
  PRIVATE Qt5::Core Qt5::Quick)

set_target_properties(${PROJECT_NAME} PROPERTIES
  AUTOUIC ON
  AUTOMOC ON
  AUTORCC ON
)