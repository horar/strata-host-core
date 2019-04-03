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

    check_cxx_compiler_flag("-pipe" HAVE_PIPE)
    if(HAVE_PIPE)
        add_compile_options("-pipe")
    endif()
endif()
