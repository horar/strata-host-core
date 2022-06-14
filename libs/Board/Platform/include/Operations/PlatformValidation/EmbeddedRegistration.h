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

class EmbeddedRegistration : public BaseValidation {
    Q_OBJECT
    Q_DISABLE_COPY(EmbeddedRegistration)

public:
    /*!
     * EmbeddedRegistration constructor.
     * \param platform platform which will be used for validation
     */
    EmbeddedRegistration(const PlatformPtr& platform);

    /*!
     * EmbeddedRegistration destructor.
     */
    ~EmbeddedRegistration() = default;

private:
    ValidationResult requestPlatformIdCheck1();
    ValidationResult requestPlatformIdCheck(bool unsetId);
    void beforeStartBootloader();
    void afterStartBootloader(command::CommandResult& result, int& status);
    ValidationResult setPlatformIdCheck(bool expectFailure, bool assisted);
    void beforeSetIdFailure();
    void afterSetIdFailure(command::CommandResult& result, int& status);
    void afterStartApplication(command::CommandResult& result, int& status);

    const QString fakeUuid4_;
    const quint64 fakeBoardCount_;
};

}  // namespace
