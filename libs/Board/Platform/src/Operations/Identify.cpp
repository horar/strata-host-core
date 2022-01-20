/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <Operations/Identify.h>
#include "Commands/PlatformCommands.h"

#include <QTimer>

namespace strata::platform::operation {

using command::CmdGetFirmwareInfo;
using command::CmdRequestPlatformId;
using command::CmdWait;

Identify::Identify(const PlatformPtr& platform,
                   bool requireFwInfoResponse,
                   uint maxFwInfoRetries,
                   std::chrono::milliseconds delay)
    : BasePlatformOperation(platform, Type::Identify)
{
    commandList_.reserve(3);

    // BasePlatformOperation member platform_ must be used as a parameter for commands!
    if (delay > std::chrono::milliseconds(0)) {
        commandList_.emplace_back(std::make_unique<CmdWait>(platform_, delay, QStringLiteral("Waiting for board to boot")));
    }
    commandList_.emplace_back(std::make_unique<CmdGetFirmwareInfo>(platform_, requireFwInfoResponse, maxFwInfoRetries));
    commandList_.emplace_back(std::make_unique<CmdRequestPlatformId>(platform_));

    initCommandList();

    postOperationHandler_ = std::bind(&Identify::setPlatformRecognized, this, std::placeholders::_1);
}

Identify::BoardMode Identify::boardMode()
{
    if (BasePlatformOperation::isSuccessfullyFinished()) {
        if (BasePlatformOperation::bootloaderMode()) {
            return BoardMode::Bootloader;
        } else {
            return BoardMode::Application;
        }
    }

    return BoardMode::Unknown;
}

void Identify::setPlatformRecognized(Result result) {
    // do not emit recognized signal if operation was cancelled or never started
    if ((result != Result::Cancel) && hasStarted()) {
        BasePlatformOperation::setPlatformRecognized(result == Result::Success);
    }
}

}  // namespace
