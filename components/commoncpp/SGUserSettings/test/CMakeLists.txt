##
## Copyright (c) 2018-2021 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
add_executable(test-${PROJECT_NAME}
    main.cpp
    SGUserSettings-test.cpp
)

target_link_libraries(test-${PROJECT_NAME}
    PRIVATE SGUserSettings
    PRIVATE gtest::gtest
)

add_test(NAME test-${PROJECT_NAME}
    COMMAND test-${PROJECT_NAME}
)
