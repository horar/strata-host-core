/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <Operations/PlatformValidation/BaseValidation.h>

namespace strata::platform::validation {

class Identification : public BaseValidation {
    Q_OBJECT
    Q_DISABLE_COPY(Identification)

public:
    /*!
     * Identification constructor.
     * \param platform platform which will be used for validation
     */
    Identification(const PlatformPtr& platform);

    /*!
     * Identification destructor.
     */
    ~Identification() = default;

private:
    /*!
     * Checks notification from 'get_firmware_info' commnad.
     * \return true if 'get_firmware_info' notification is OK, otherwise false
     */
    bool getFirmwareInfoCheck();

    /*!
     * Checks notification from 'request_platform_id' commnad.
     * \return true if 'request_platform_id' notification is OK, otherwise false
     */
    bool requestPlatformIdCheck();
};

}  // namespace
