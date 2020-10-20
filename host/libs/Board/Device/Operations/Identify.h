#pragma once

#include <chrono>

#include <Device/Operations/BaseDeviceOperation.h>

namespace strata::device::operation {

class Identify : public BaseDeviceOperation {

public:
    /*!
     * Identify operation constructor
     * \param device device which will be used for operation
     * \param requireFwInfoResponse true if response to 'get_firmware_info' command is required
     */
    Identify(const device::DevicePtr& device, bool requireFwInfoResponse);

    /*!
     * Identify operation constructor
     * \param device device which will be used for operation
     * \param maxFwInfoRetries max number of retries for 'get_firmware_info' command
     * Response to 'get_firmware_info' command is required.
     * If maxFwInfoRetries is 2, 'get_firmware_info' command can be sent 3 times (1 regular + 2 retries).
     */
    explicit Identify(const device::DevicePtr& device, uint maxFwInfoRetries = 0);

    /*!
     * Identify operation destructor
     */
    ~Identify() = default;

    /*!
     * Run (start) operation with delay
     * \param delay number of milliseconds before running operation
     */
    void runWithDelay(std::chrono::milliseconds delay);
};

}  // namespace
