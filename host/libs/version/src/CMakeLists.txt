add_library(${PROJECT_NAME} STATIC)

target_sources(${PROJECT_NAME} PRIVATE
    StrataVersion.cpp
    StrataVersion.cpp.in
)

set_source_files_properties(
    StrataVersion.cpp
    PROPERTIES
        GENERATED true
)

set_target_properties(${PROJECT_NAME}
    PROPERTIES LINKER_LANGUAGE CXX
)

include(StrataVersion)

target_include_directories(${PROJECT_NAME} PUBLIC
    ${PROJECT_SOURCE_DIR}/include
)
