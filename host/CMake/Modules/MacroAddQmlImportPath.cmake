macro(add_qml_import_path)
    set(qmlImportPath PATH)
    cmake_parse_arguments(local "" "${qmlImportPath}" "" ${ARGN})

    message(STATUS "...updating QML import path with with: '${local_PATH}'")

    # [LC] update QML mobule import paths for this project here
    set(QML_DIRS "${QML_IMPORT_PATH}")
    list(APPEND QML_DIRS "${local_PATH}")
    list(REMOVE_DUPLICATES "${QML_DIRS}")

    # Additional import path used to resolve QML modules in Qt Creator's code model
    set(QML_IMPORT_PATH "${QML_DIRS}"
        CACHE STRING "Qt Creator extra qml import paths" FORCE
    )
endmacro()
