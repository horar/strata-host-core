#
# monaco-editor
# This will download and install a third party IDE Editor resource into the extern build folder
# Because this repo does not have source code in Git and is already compiled, the resource can
# simply be unarchived and the min/vs,min-maps/vs, and the monaco.d.ts can be "installed" to the build folder
#
set(MONACO_TAG 0.20.0)

file(GLOB_RECURSE INSTALLED ${EXTERN_INSTALL_DIR_PATH}/monaco-editor-${MONACO_TAG}/monaco.d.ts)
if(INSTALLED)
    file(REMOVE_RECURSE ${EXTERN_INSTALL_DIR_PATH}/monaco-editor-${MONACO_TAG}/)
    file(REMOVE_RECURSE ${EXTERN_INSTALL_DIR_PATH}/../extern/monaco-editor-${MONACO_TAG}-prefix/)
endif() 

    ExternalProject_Add(monaco-editor-${MONACO_TAG}
        SOURCE_DIR ${SOURCE_DIR_EXTERN}/monaco-editor-${MONACO_TAG}/package
        INSTALL_DIR ${EXTERN_INSTALL_DIR_PATH}/monaco-editor-${MONACO_TAG}
        DOWNLOAD_DIR ${SOURCE_DIR_EXTERN}/monaco-editor-${MONACO_TAG}/tar
        BUILD_ALWAYS ON
        URL https://registry.npmjs.org/monaco-editor/-/monaco-editor-${MONACO_TAG}.tgz
        URL_HASH SHA1=5d5009343a550124426cb4d965a4d27a348b4dea
        CONFIGURE_COMMAND ""
        COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/monaco.d.ts <INSTALL_DIR>/monaco.d.ts          
        COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/../editor.html <INSTALL_DIR>/editor.html                    
        COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/min/vs <INSTALL_DIR>/min/vs 
        COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/min-maps/vs <INSTALL_DIR>/min-maps/vs 
        BUILD_COMMAND ""
        INSTALL_COMMAND ""   
    )


