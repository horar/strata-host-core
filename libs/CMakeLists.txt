##
## Copyright (c) 2018-2021 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
add_subdirectory(base64)
add_subdirectory(crc16)
add_subdirectory(connector)
add_subdirectory(flasher)
if((APPS_CORESW AND APPS_CORESW_SDS) OR APPS_UTILS)
    add_subdirectory(PlatformInterface)
endif()
add_subdirectory(CommandValidator)
add_subdirectory(loggers)
add_subdirectory(Board)
if((APPS_CORESW AND APPS_CORESW_HCS) OR (APPS_TOOLBOX AND APPS_TOOLBOX_PRT))
    add_subdirectory(DownloadManager)
endif()
if((APPS_CORESW AND APPS_CORESW_HCS) OR BUILD_RS)
    add_subdirectory(Database)
endif()
add_subdirectory(StrataRPC)
