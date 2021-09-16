project(SGQwtPlot
    VERSION 1.0
    LANGUAGES CXX
)

find_package(Qt5 ${VERSION_QT5}
    COMPONENTS Core Quick Widgets
    REQUIRED
)

add_library(${PROJECT_NAME}
    include/SGQwtPlot.h
    include/SGQwtPlotCurve.h
    include/SGQwtPlotCurveData.h

    src/SGQwtPlot.cpp
    src/SGQwtPlotCurve.cpp
    src/SGQwtPlotCurveData.cpp

    src/logging/LoggingQtCategories.cpp
)

add_library(strata::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC
    Qt5::Core
    Qt5::Quick
    Qt5::Widgets
    qwt::qwt
    strata::QtLogger
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)

if(BUILD_TESTING)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/test/CMakeLists.txt")
        add_subdirectory(test)
    endif()
endif()
