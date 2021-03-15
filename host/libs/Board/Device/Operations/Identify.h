#pragma once

#include <chrono>

#include <Device/Operations/BaseDeviceOperation.h>

namespace strata::device::operation {

class Identify : public BaseDeviceOperation {

public:
    enum class BoardMode {
        Unknown,
        Application,
        Bootloader
    };

    /*!
     * Identify operation constructor
     * \param device device which will be used for operation
     * \param requireFwInfoResponse true if response to 'get_firmware_info' command is required
     * \param maxFwInfoRetries max number of retries for 'get_firmware_info' command
     * \param delay number of milliseconds for waiting before sending first operation command
     * If maxFwInfoRetries is 2, 'get_firmware_info' command can be sent 3 times (1 regular + 2 retries).
     */
    Identify(const device::DevicePtr& device,
             bool requireFwInfoResponse,
             uint maxFwInfoRetries = 1,
             std::chrono::milliseconds delay = std::chrono::milliseconds(0));

    /*!
     * Identify operation destructor
     */
    ~Identify() = default;

    /*!
     * Checks if board is in bootloader or application mode.
     * \return value from BoardMode enum
     */
    BoardMode boardMode();
};

}  // namespace
