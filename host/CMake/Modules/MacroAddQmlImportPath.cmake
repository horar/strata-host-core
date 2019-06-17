macro(add_qml_import_path)
    set(qmlImportPath PATH)
    cmake_parse_arguments(local "" "${qmlImportPath}" "" ${ARGN})

    set(QML_DIRS "${QML_IMPORT_PATH}")
    if(NOT ${local_PATH} IN_LIST QML_DIRS)
        # Additional import path used to resolve QML modules in Qt Creator's code model
        set(QML_IMPORT_PATH "${local_PATH};${QML_IMPORT_PATH}"
            CACHE STRING "Qt Creator extra qml import paths" FORCE
        )
        message(STATUS "... updated QML import path with: '${local_PATH}'")
    endif()
endmacro()
