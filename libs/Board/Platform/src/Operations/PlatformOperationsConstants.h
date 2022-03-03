/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <chrono>

namespace strata::platform::operation {

// Legacy note related to EFM boards:
// Bootloader takes 5 seconds to start (known issue related to clock source).
// Platform and bootloader uses the same setting for clock source.
// Clock source for bootloader and application must match. Otherwise when application
// jumps to bootloader, it will have a hardware fault which requires board to be reset.
constexpr std::chrono::milliseconds BOOTLOADER_BOOT_TIME(5500);

// Bypasses the 5 seconds wait time for test purposes.
constexpr std::chrono::milliseconds BOOTLOADER_MOCK_BOOT_TIME(1);

constexpr unsigned int MAX_GET_FW_INFO_RETRIES(5);

}
