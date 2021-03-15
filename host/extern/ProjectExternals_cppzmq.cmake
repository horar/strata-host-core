#
# cppzmq (c++ headers only zmq wrapper)
#
get_git_hash_and_installation_status("${SOURCE_DIR_EXTERN}/cppzmq" "${EXTERN_INSTALL_DIR_PATH}/cppzmq")

add_library(zeromq::cppzmq INTERFACE IMPORTED GLOBAL)

set_target_properties(zeromq::cppzmq PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${EXTERN_INSTALL_DIR_PATH}/cppzmq-${GIT_HASH}/include"
)

add_dependencies(zeromq::cppzmq DEPENDS zeromq::libzmq)

file(COPY "${SOURCE_DIR_EXTERN}/cppzmq/zmq.hpp" DESTINATION "${EXTERN_INSTALL_DIR_PATH}/cppzmq-${GIT_HASH}/include")
file(COPY "${SOURCE_DIR_EXTERN}/cppzmq/zmq_addon.hpp" DESTINATION "${EXTERN_INSTALL_DIR_PATH}/cppzmq-${GIT_HASH}/include")
