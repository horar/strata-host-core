project(flasher
    VERSION 1.0
    LANGUAGES CXX
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core
    REQUIRED
)

#add_library(${PROJECT_NAME}
#    src/Flasher.cpp
#)

# temporarily disabled (CS-468)
#add_library(${PROJECT_NAME}Connector
#    src/FlasherConnector.cpp
#    #AUTOMOC wont find header if it is in different directory
#    include/FlasherConnector.h
#)

#target_include_directories(${PROJECT_NAME}Connector
#    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
#)

#target_link_libraries(${PROJECT_NAME}Connector
#    PUBLIC Qt5::Core ${PROJECT_NAME}
#)

#set_target_properties(${PROJECT_NAME}Connector PROPERTIES
#    AUTOMOC ON
#)


add_library(${PROJECT_NAME}
    src/Flasher.cpp
    src/logging/LoggingQtCategories.cpp
    #AUTOMOC wont find header if it is in different directory
    include/Flasher.h
    src/logging/LoggingQtCategories.h
)

target_include_directories(${PROJECT_NAME}
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC Qt5::Core
    PUBLIC QtLogger
    PUBLIC SerialDevice
    PUBLIC DeviceOperations
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)
