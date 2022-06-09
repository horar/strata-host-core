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

class BtldrAppPresence : public BaseValidation {
    Q_OBJECT
    Q_DISABLE_COPY(BtldrAppPresence)

public:
    /*!
     * BtldrAppPresence constructor.
     * \param platform platform which will be used for validation
     */
    BtldrAppPresence(const PlatformPtr& platform);

    /*!
     * BtldrAppPresence destructor.
     */
    ~BtldrAppPresence() = default;

private:
    void copyFatalFailure();
    void editCommandResult(command::CommandResult& result, int& status);
    ValidationResult startCheck();
    ValidationResult getFirmwareInfoCheck(bool bootloaderActive);

    bool copiedFatalFailure_;
};

}  // namespace
