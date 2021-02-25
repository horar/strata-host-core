project(OktaWebView
    DESCRIPTION "Login/Singup webiew for AAA/Okta sample integration"
    LANGUAGES CXX
)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Quick WebEngineCore WebEngine Qml
    REQUIRED
)

add_executable(${PROJECT_NAME}
  main.cpp
  pkcegenerator.cpp
  urlquery.cpp
  url.cpp
  qml.qrc
)

target_compile_definitions(${PROJECT_NAME}
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME}
  PRIVATE Qt5::Core
  Qt5::Quick
  Qt5::WebEngineCore
  Qt5::WebEngine
  Qt5::Qml
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
    AUTORCC ON
)

