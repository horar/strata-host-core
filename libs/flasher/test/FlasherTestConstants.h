/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QByteArray>

// data for fake firmware/bootloader
namespace strata::FlasherTestConstants {

// default timeout for QTRY_COMPARE_WITH_TIMEOUT
constexpr int TEST_TIMEOUT = 1000;

} // namespace strata::FlasherTestConstants
