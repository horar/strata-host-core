#pragma once

#include <chrono>

namespace strata {

constexpr std::chrono::milliseconds IDENTIFY_LAUNCH_DELAY(500);
constexpr unsigned int GET_FW_INFO_MAX_RETRIES(2);

}  // namespace
