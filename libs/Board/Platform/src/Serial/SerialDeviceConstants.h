/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef SERIAL_DEVICE_CONSTANTS_H
#define SERIAL_DEVICE_CONSTANTS_H

#include <chrono>

namespace strata::device {

constexpr unsigned READ_BUFFER_SIZE = 4096;
constexpr std::chrono::milliseconds SERIAL_DEVICE_OPEN_RETRY_INTERVAL(1000);

}  // namespace

#endif // SERIAL_DEVICE_CONSTANTS_H
