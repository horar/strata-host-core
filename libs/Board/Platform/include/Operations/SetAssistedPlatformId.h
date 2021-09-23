/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <Operations/BasePlatformOperation.h>
#include <PlatformOperationsData.h>

namespace strata::platform::command {
    class CmdSetAssistedPlatformId;
}

namespace strata::platform::operation {

class SetAssistedPlatformId : public BasePlatformOperation {

public:
    explicit SetAssistedPlatformId(const PlatformPtr& platform);

    ~SetAssistedPlatformId() = default;

    void setBaseData(const command::CmdSetPlatformIdData &data);
    void setControllerData(const command::CmdSetPlatformIdData &controllerData);
    void setFwClassId(const QString &fwClassId);

private:
    command::CmdSetAssistedPlatformId* cmdSetAssistPlatfId_;
};

}  // namespace
