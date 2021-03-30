#ifndef BOARD_MANAGER_CONSTANTS_H
#define BOARD_MANAGER_CONSTANTS_H

#include <chrono>

namespace strata {

constexpr std::chrono::milliseconds DEVICE_CHECK_INTERVAL(1000);
constexpr std::chrono::milliseconds IDENTIFY_LAUNCH_DELAY(500);
constexpr unsigned int GET_FW_INFO_MAX_RETRIES(2);

}  // namespace

#endif
