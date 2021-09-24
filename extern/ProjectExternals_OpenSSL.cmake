##
## Copyright (c) 2018-2021 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##

#
# MacOS: Find (or install) OpenSSL through Homebrew
#

if(APPLE)
    # Check cached variables for previously set path
    if(DEFINED SSL_LIB_PATH_MACOS AND NOT SSL_LIB_PATH_MACOS STREQUAL "")
        message(STATUS "OpenSSL libraries directory found in cache: ${SSL_LIB_PATH_MACOS}")

    # Use Homebrew to search for OpenSSL@1.1, install it if not found
    else()
        find_program(BREW_PROGRAM brew)
        mark_as_advanced(BREW_PROGRAM)

        if(BREW_PROGRAM)
            find_program(SED_PROGRAM sed)
            mark_as_advanced(SED_PROGRAM)

            find_program(BASH_PROGRAM bash)
            mark_as_advanced(BASH_PROGRAM)

            if(BASH_PROGRAM AND SED_PROGRAM)
                execute_process(COMMAND "${BASH_PROGRAM}" "-c" "${BREW_PROGRAM} config | ${SED_PROGRAM} -n -E 's/^HOMEBREW_PREFIX: (.+)$$/\\1/p'" OUTPUT_VARIABLE HOMEBREW_PREFIX)
                string(STRIP "${HOMEBREW_PREFIX}" HOMEBREW_PREFIX)
                unset(OPEN_SSL_OUTPUT)
                execute_process(COMMAND "${BASH_PROGRAM}" "-c" "${BREW_PROGRAM} ls --versions openssl@1.1" OUTPUT_VARIABLE OPEN_SSL_OUTPUT)
                if("${OPEN_SSL_OUTPUT}" STREQUAL "")
                    # Result is empty -- OpenSSL not found
                    # Install OpenSSL
                    execute_process(COMMAND "${BASH_PROGRAM}" "-c" "${BREW_PROGRAM} install openssl@1.1")
                    message(STATUS "Installed OpenSSL@1.1 through Homebrew.")
                else()
                    message(STATUS "Found OpenSSL@1.1 installation through Homebrew.")
                endif()
                set(SSL_LIB_PATH_MACOS "${HOMEBREW_PREFIX}/opt/openssl@1.1" CACHE STRING "Directory containing OpenSSL" FORCE)
            endif()
        else()
            message(FATAL_ERROR "Homebrew must be installed to continue compilation.")
        endif()
    endif()
endif()
