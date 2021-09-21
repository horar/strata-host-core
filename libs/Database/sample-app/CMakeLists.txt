##
## Copyright (c) 2018-2021 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##
add_executable(DatabaseManager-sampleapp
    DatabaseManager-sampleapp.cpp
)

add_executable(Database-sampleapp
    couchbase-database-sampleapp.cpp
)

target_link_libraries(DatabaseManager-sampleapp
    PUBLIC
    Database
)

target_link_libraries(Database-sampleapp
    PUBLIC
    Database
)
