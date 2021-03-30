# create a replicator credentials

string(APPEND username ${USERNAME})
string(APPEND password ${PASSWORD})

message(STATUS "Processing replicator credentials info for ${PROJECT_NAME}...")
file(READ ${INPUT_DIR}/ReplicatorCredentials.cpp.in rcFile_temporary)
string(CONFIGURE "${rcFile_temporary}" rcFile_updated @ONLY)
file(WRITE ${OUTPUT_DIR}/ReplicatorCredentials.cpp.tmp "${rcFile_updated}")
execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${OUTPUT_DIR}/ReplicatorCredentials.cpp.tmp ${OUTPUT_DIR}/ReplicatorCredentials.cpp
)
