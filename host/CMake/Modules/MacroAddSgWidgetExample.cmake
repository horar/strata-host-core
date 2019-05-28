macro(add_sgwidget_example)
    set(projectName NAME)
    cmake_parse_arguments(local "" "${projectName}" "" ${ARGN})

    message(STATUS "${local_NAME}... ")

    add_executable(${local_NAME}
        main.cpp
        main.qrc
    )

    target_compile_definitions(${local_NAME} PRIVATE
        $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
    )

    target_link_libraries(${local_NAME} PRIVATE
        Qt5::Core
        Qt5::Quick
    )

    set_target_properties(${local_NAME} PROPERTIES
        CXX_STANDARD 17
        CXX_STANDARD_REQUIRED ON
        CXX_EXTENSIONS OFF

        AUTOMOC ON
        AUTORCC ON
    )
endmacro()
