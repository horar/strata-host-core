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
#include <PlatformOperationsData.h>

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
    ValidationResult requestPlatformIdCheck(bool unsetId);
    void beforeStartBootloader();
    void afterStartBootloader(command::CommandResult& result, int& status);
    ValidationResult setPlatformIdCheck(bool expectFailure, bool assisted);
    void beforeSetIdFailure();
    void afterSetIdFailure(command::CommandResult& result, int& status);
    void afterStartApplication(command::CommandResult& result, int& status);

    void logAndEmitUnexpectedValue(const QVector<const char*>& path,
                                   const char* key,
                                   const QString& current,
                                   const QString& expected);

    command::CmdSetPlatformIdData data_;
};

}  // namespace
