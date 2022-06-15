/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include "BaseValidation.h"

#include <PlatformOperationsData.h>

namespace strata::platform::validation {

class AssistedRegistration : public BaseValidation {
    Q_OBJECT
    Q_DISABLE_COPY(AssistedRegistration)

public:
    /*!
     * AssistedRegistration constructor.
     * \param platform platform which will be used for validation
     */
    AssistedRegistration(const PlatformPtr& platform, const QString& name);

    /*!
     * AssistedRegistration destructor.
     */
    ~AssistedRegistration() = default;

private:
    ValidationResult requestPlatformIdCheck(bool unsetId);
    void beforeStartBootloader();
    void afterStartBootloader(command::CommandResult& result, int& status);
    ValidationResult setPlatformIdCheck(bool expectFailure, bool assisted);
    void beforeSetIdFailure();
    void afterSetIdFailure(command::CommandResult& result, int& status);
    void afterAssistedConnectedCheck(command::CommandResult& result, int& status);
    void afterStartApplication(command::CommandResult& result, int& status);

    void skipNextCommand();

    command::CmdSetPlatformIdData data_;
    command::CmdSetPlatformIdData controllerData_;
    QString fwClassId1_;
    QString fwClassId2_;
    bool assistedBoardConnected_;
};

}  // namespace
