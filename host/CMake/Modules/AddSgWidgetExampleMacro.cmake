macro(add_sgwidget_example)
    set(projectName NAME)
    cmake_parse_arguments(local "" "${projectName}" "" ${ARGN})

    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/main.cpp")
        message(STATUS "${local_NAME}... skipping")
    else()
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
            AUTOMOC ON
            AUTORCC ON
        )
    endif()
endmacro()
