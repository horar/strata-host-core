include(CheckCXXCompilerFlag)

if(UNIX)
    check_cxx_compiler_flag("-Wall" HAVE_WALL)
    if(HAVE_WALL)
        add_compile_options("-Wall")
    endif()

    check_cxx_compiler_flag("-Wextra" HAVE_WEXTRA)
    if(HAVE_WEXTRA)
        add_compile_options("-Wextra")
    endif()

    check_cxx_compiler_flag("-w" HAVE_W)
    if(HAVE_W)
        option(COMPILER_W "Inhibit all warning messages" OFF)
        add_feature_info(COMPILER_W COMPILER_W "Inhibit all warning messages")
        if(COMPILER_W)
            add_compile_options("-w")
        endif()
    endif()

    check_cxx_compiler_flag("-Werror" HAVE_WERROR)
    if(HAVE_WERROR)
        option(COMPILER_WERROR "Make all warnings into errors" OFF)
        add_feature_info(COMPILER_WERROR COMPILER_WERROR "Make all warnings into errors")
        if(COMPILER_WERROR)
            add_compile_options("-Werror")
        endif()
    endif()

    check_cxx_compiler_flag("-pipe" HAVE_PIPE)
    if(HAVE_PIPE)
        add_compile_options("-pipe")
    endif()

    check_cxx_compiler_flag("-Wno-c++98-compat" HAVE_CPP98_COMPAT)
    if(HAVE_CPP98_COMPAT)
        add_compile_options("-Wno-c++98-compat")
    endif()

    check_cxx_compiler_flag("-Wshadow" HAVE_SHADOW)
    if(HAVE_SHADOW)
        add_compile_options("-Wshadow")
    endif()

    check_cxx_compiler_flag("-Wformat=2" HAVE_FORMAT2)
    if(HAVE_FORMAT2)
        add_compile_options("-Wformat=2")
    endif()

    check_cxx_compiler_flag("-Wconversion" HAVE_CONVERSION)
    if(HAVE_CONVERSION)
        option(COMPILER_WCONVERSION "Arithmetic operations are performed on integer types" OFF)
        add_feature_info(COMPILER_WCONVERSION COMPILER_WCONVERSION "Arithmetic operations are performed on integer types")
        if(COMPILER_WCONVERSION)
            add_compile_options("-Wconversion")
        endif()
    endif()
endif()

option(COMPILER_QTMSGCTX "Provides additional information about a log message (Qt) in non-debug builds" OFF)
add_feature_info(COMPILER_QTMSGCTX COMPILER_QTMSGCTX "Provides additional information about a log message (Qt) in non-debug builds")
if(COMPILER_QTMSGCTX)
    add_compile_definitions($<$<OR:$<CONFIG:Release>,$<CONFIG:OTA>>:QT_MESSAGELOGCONTEXT>)
endif()

if(WIN32)
    add_compile_definitions(WIN32_LEAN_AND_MEAN)
endif()

# OTA CMake build type (LC: just an alias to Release type)
set(CMAKE_CXX_FLAGS_OTA "${CMAKE_CXX_FLAGS_RELEASE}" CACHE STRING
    "Flags used by the C++ compiler during OTA builds." FORCE
)
set(CMAKE_C_FLAGS_OTA "${CMAKE_C_FLAGS_RELEASE}" CACHE STRING
    "Flags used by the C compiler during OTA builds." FORCE
)
set(CMAKE_EXE_LINKER_FLAGS_OTA "${CMAKE_EXE_LINKER_FLAGS_RELEASE}" CACHE STRING
    "Flags used for linking binaries during OTA builds." FORCE
)
set(CMAKE_SHARED_LINKER_FLAGS_OTA "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}" CACHE STRING
    "Flags used by the shared libraries linker during OTA builds." FORCE
)
set(CMAKE_MODULE_LINKER_FLAGS_OTA "${CMAKE_MODULE_LINKER_FLAGS_RELEASE}" CACHE STRING
    "Flags used by the module libraries linker during OTA builds." FORCE
)
MARK_AS_ADVANCED(
    CMAKE_CXX_FLAGS_OTA
    CMAKE_C_FLAGS_OTA
    CMAKE_EXE_LINKER_FLAGS_OTA
    CMAKE_SHARED_LINKER_FLAGS_OTA
    CMAKE_MODULE_LINKER_FLAGS_OTA
)
# Update the documentation string of CMAKE_BUILD_TYPE for GUIs
set(CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE}" CACHE STRING
    "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel OTA." FORCE
)
