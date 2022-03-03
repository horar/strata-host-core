##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
add_executable(test-database
    main.cpp
    couchbase-database-test.cpp
)

target_link_libraries(test-database
    PRIVATE Database
    PRIVATE gtest::gtest
)

add_test(NAME test-database
    COMMAND test-database
)
