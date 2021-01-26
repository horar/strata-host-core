if(NOT SET_UP_CONFIGURATIONS_DONE)
    set(SET_UP_CONFIGURATIONS_DONE 1)

    # No reason to set CMAKE_CONFIGURATION_TYPES if it's not a multiconfig generator
    # Also no reason mess with CMAKE_BUILD_TYPE if it's a multiconfig generator.
    if(CMAKE_CONFIGURATION_TYPES) # multiconfig generator?
        message(FATAL_ERROR "CMake multiconfig generators are not supported!!")
    else()
        if(NOT CMAKE_BUILD_TYPE)
            message(STATUS "Defaulting to 'Debug' build.")
            set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose the type of build" FORCE)
        endif()
        set(CMAKE_BUILD_TYPE_CHOICES "Debug" "Release" "RelWithDebInfo" "MinSizeRel" "OTA")
        set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${CMAKE_BUILD_TYPE_CHOICES})
        if(NOT CMAKE_BUILD_TYPE IN_LIST CMAKE_BUILD_TYPE_CHOICES)
            message(FATAL_ERROR "Specify 'CMAKE_BUILD_TYPE'. Must be one of ${CMAKE_BUILD_TYPE_CHOICES}")
        endif()
    endif()
endif()
