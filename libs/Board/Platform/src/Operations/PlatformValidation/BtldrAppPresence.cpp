/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <Operations/PlatformValidation/BtldrAppPresence.h>
#include <Commands/PlatformCommands.h>
#include <Commands/PlatformCommandConstants.h>

#include "logging/LoggingQtCategories.h"

#include <QLatin1String>

namespace strata::platform::validation {

BtldrAppPresence::BtldrAppPresence(const PlatformPtr& platform)
    : BaseValidation(platform, Type::BtldrAppPresence, QStringLiteral("Bootloader & Application presence"))
{
    commandList_.reserve(4);

    // BaseValidation member platform_ must be used as a parameter for commands!
    commandList_.emplace_back(std::make_unique<command::CmdStartBootloader>(platform_),
                              std::bind(&BtldrAppPresence::copyFatalFailure, this),
                              std::bind(&BtldrAppPresence::editCommandResult, this, std::placeholders::_1, std::placeholders::_2),
                              std::bind(&BtldrAppPresence::startCheck, this));
    commandList_.emplace_back(std::make_unique<command::CmdGetFirmwareInfo>(platform_, true, 0),
                              nullptr,
                              nullptr,
                              std::bind(&BtldrAppPresence::getFirmwareInfoCheck, this, true));
    commandList_.emplace_back(std::make_unique<command::CmdStartApplication>(platform_),
                              std::bind(&BtldrAppPresence::copyFatalFailure, this),
                              std::bind(&BtldrAppPresence::editCommandResult, this, std::placeholders::_1, std::placeholders::_2),
                              std::bind(&BtldrAppPresence::startCheck, this));
    commandList_.emplace_back(std::make_unique<command::CmdGetFirmwareInfo>(platform_, true, 0),
                              nullptr,
                              nullptr,
                              std::bind(&BtldrAppPresence::getFirmwareInfoCheck, this, false));
}

void BtldrAppPresence::copyFatalFailure()
{
    copiedFatalFailure_ = fatalFailure_;
}

void BtldrAppPresence::editCommandResult(command::CommandResult& result, int& status)
{
    Q_UNUSED(status)

    switch (result) {
    case command::CommandResult::Reject :  // Command was not found.
        // If command is not found act as everything is OK.
        result = command::CommandResult::Done;
        fatalFailure_ = copiedFatalFailure_;
        {
            QString message(QStringLiteral("Command was not found, ignoring it"));
            qCWarning(lcPlatformValidation) << platform_ << message;
            emit validationStatus(Status::Warning, message);
        }
        break;
    case command::CommandResult::Failure :  // "start_bootloader" failed.
    case command::CommandResult::FinaliseOperation :  // "start_application" failed.
        // We want to end this validation as "INCOMPLETE" if cannot start to application or bootloader.
        // So act as everything is OK and there are another checks in 'startCheck()' method
        // which is called in 'BaseValidation.cpp' as 'currentCommand_->notificationCheck()'.
        result = command::CommandResult::Done;
        break;
    default :
        break;
    }
}

BaseValidation::ValidationResult BtldrAppPresence::startCheck()
{
    using namespace strata::platform::command;

    const rapidjson::Document& json = lastPlatformNotification_.json();

    if (generalNotificationCheck(json, currentCommand_->command->name()) == false) {
        return ValidationResult::Failed;
    }

    const rapidjson::Value& payload = json[JSON_NOTIFICATION][JSON_PAYLOAD];
    QVector<const char*> jsonPath({JSON_NOTIFICATION, JSON_PAYLOAD});  // successfuly checked JSON path

    {  // check "status"
        if (checkKey(payload, JSON_STATUS, KeyType::String, jsonPath) == false) {
            return ValidationResult::Failed;
        }
        const rapidjson::Value& status = payload[JSON_STATUS];
        QLatin1String statusStr(status.GetString(), status.GetStringLength());
        if (statusStr != JSON_OK) {
            QString message = QStringLiteral("Bad result of '") + currentCommand_->command->name() + QStringLiteral("': ") + statusStr;
            qCWarning(lcPlatformValidation) << platform_ << message;
            emit validationStatus(Status::Warning, message);
            incomplete_ = true;
        }
    }

    return ValidationResult::Passed;
}

BaseValidation::ValidationResult BtldrAppPresence::getFirmwareInfoCheck(bool bootloaderActive)
{
    using namespace strata::platform::command;

    const rapidjson::Document& json = lastPlatformNotification_.json();

    if (generalNotificationCheck(json, currentCommand_->command->name()) == false) {
        return ValidationResult::Failed;
    }

    const rapidjson::Value& payload = json[JSON_NOTIFICATION][JSON_PAYLOAD];
    QVector<const char*> jsonPath({JSON_NOTIFICATION, JSON_PAYLOAD});  // successfuly checked JSON path

    // check "api_version"
    if (checkKey(payload, JSON_API_VERSION, KeyType::String, jsonPath) == false) {
        QString message(QStringLiteral("Probably legacy API version 1"));
        qCWarning(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Error, message);
        return ValidationResult::Failed;
    }

    {  // check "active"
        if (checkKey(payload, JSON_ACTIVE, KeyType::String, jsonPath) == false) {
            return ValidationResult::Failed;
        }
        const rapidjson::Value& active = payload[JSON_ACTIVE];
        QLatin1String activeStr(active.GetString(), active.GetStringLength());
        bool ok = false;
        QString message;
        if (bootloaderActive) {
            message = QStringLiteral("Bootloader");
            if (activeStr == CSTR_BOOTLOADER) {
                ok = true;
            }
        } else {
            message = QStringLiteral("Application");
            if (activeStr == CSTR_APPLICATION) {
                ok = true;
            }
        }
        if (ok) {
            message += QStringLiteral(" present");
            qCInfo(lcPlatformValidation) << platform_ << message;
            emit validationStatus(Status::Success, message);
        } else {
            message += QStringLiteral(" is not active");
            incomplete_ = true;
            qCWarning(lcPlatformValidation) << platform_ << message;
            emit validationStatus(Status::Warning, message);
        }
    }

    return ValidationResult::Passed;
}

}  // namespace
