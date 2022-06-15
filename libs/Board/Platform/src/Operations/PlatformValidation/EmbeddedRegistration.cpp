/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <Operations/PlatformValidation/EmbeddedRegistration.h>
#include <Commands/PlatformCommands.h>
#include <Commands/PlatformCommandConstants.h>
#include <PlatformOperationsStatus.h>
#include <PlatformOperationsData.h>

#include "logging/LoggingQtCategories.h"

#include <QLatin1String>

#include <array>

namespace strata::platform::validation {

EmbeddedRegistration::EmbeddedRegistration(const PlatformPtr& platform)
    : BaseValidation(platform, QStringLiteral("Embedded board registration")),
      fakeUuid4_("00000000-0000-4000-8000-000000000000"),
      fakeBoardCount_(1)
{
    command::CmdSetPlatformIdData data;
    data.classId = fakeUuid4_;
    data.platformId = fakeUuid4_;
    data.boardCount = fakeBoardCount_;

    commandList_.reserve(11);

    // BaseValidation member platform_ must be used as a parameter for commands!

    commandList_.emplace_back(std::make_unique<command::CmdRequestPlatformId>(platform_),
                              nullptr,
                              nullptr,
                              std::bind(&EmbeddedRegistration::requestPlatformIdCheck, this, true));

    commandList_.emplace_back(std::make_unique<command::CmdStartBootloader>(platform_),
                              std::bind(&EmbeddedRegistration::beforeStartBootloader, this),
                              std::bind(&EmbeddedRegistration::afterStartBootloader, this, std::placeholders::_1, std::placeholders::_2),
                              nullptr);

    commandList_.emplace_back(std::make_unique<command::CmdWait>(platform_, std::chrono::milliseconds(500), QStringLiteral("Waiting for bootloader to start")),
                              nullptr,
                              nullptr,
                              nullptr);

    commandList_.emplace_back(std::make_unique<command::CmdSetPlatformId>(platform_, data),
                              nullptr,
                              nullptr,
                              std::bind(&EmbeddedRegistration::setPlatformIdCheck, this, false, false));

    commandList_.emplace_back(std::make_unique<command::CmdSetPlatformId>(platform_, data),
                              std::bind(&EmbeddedRegistration::beforeSetIdFailure, this),
                              std::bind(&EmbeddedRegistration::afterSetIdFailure, this, std::placeholders::_1, std::placeholders::_2),
                              std::bind(&EmbeddedRegistration::setPlatformIdCheck, this, true, false));

    std::unique_ptr<command::CmdSetAssistedPlatformId> cmdSetAssistPlatfId1 = std::make_unique<command::CmdSetAssistedPlatformId>(platform_);
    cmdSetAssistPlatfId1->setAckTimeout(std::chrono::milliseconds(2000));  // special case, firmware takes too long to send ACK (see CS-1722)
    cmdSetAssistPlatfId1->setBaseData(data);
    cmdSetAssistPlatfId1->setControllerData(data);
    cmdSetAssistPlatfId1->setFwClassId(fakeUuid4_);
    commandList_.emplace_back(std::move(cmdSetAssistPlatfId1),
                              std::bind(&EmbeddedRegistration::beforeSetIdFailure, this),
                              std::bind(&EmbeddedRegistration::afterSetIdFailure, this, std::placeholders::_1, std::placeholders::_2),
                              std::bind(&EmbeddedRegistration::setPlatformIdCheck, this, true, true));

    commandList_.emplace_back(std::make_unique<command::CmdStartApplication>(platform_),
                              nullptr,
                              std::bind(&EmbeddedRegistration::afterStartApplication, this, std::placeholders::_1, std::placeholders::_2),
                              nullptr);

    commandList_.emplace_back(std::make_unique<command::CmdWait>(platform_, std::chrono::milliseconds(500), QStringLiteral("Waiting for application to start")),
                              nullptr,
                              nullptr,
                              nullptr);

    commandList_.emplace_back(std::make_unique<command::CmdSetPlatformId>(platform_, data),
                              std::bind(&EmbeddedRegistration::beforeSetIdFailure, this),
                              std::bind(&EmbeddedRegistration::afterSetIdFailure, this, std::placeholders::_1, std::placeholders::_2),
                              std::bind(&EmbeddedRegistration::setPlatformIdCheck, this, true, false));

    std::unique_ptr<command::CmdSetAssistedPlatformId> cmdSetAssistPlatfId2 = std::make_unique<command::CmdSetAssistedPlatformId>(platform_);
    cmdSetAssistPlatfId2->setAckTimeout(std::chrono::milliseconds(2000));  // special case, firmware takes too long to send ACK (see CS-1722)
    cmdSetAssistPlatfId2->setBaseData(data);
    cmdSetAssistPlatfId2->setControllerData(data);
    cmdSetAssistPlatfId2->setFwClassId(fakeUuid4_);
    commandList_.emplace_back(std::move(cmdSetAssistPlatfId2),
                              std::bind(&EmbeddedRegistration::beforeSetIdFailure, this),
                              std::bind(&EmbeddedRegistration::afterSetIdFailure, this, std::placeholders::_1, std::placeholders::_2),
                              std::bind(&EmbeddedRegistration::setPlatformIdCheck, this, true, true));

    commandList_.emplace_back(std::make_unique<command::CmdRequestPlatformId>(platform_),
                              nullptr,
                              nullptr,
                              std::bind(&EmbeddedRegistration::requestPlatformIdCheck, this, false));

}

BaseValidation::ValidationResult EmbeddedRegistration::requestPlatformIdCheck(bool unsetId)
{
    using namespace strata::platform::command;

    const rapidjson::Document& json = lastPlatformNotification_.json();

    if (generalNotificationCheck(json, QStringLiteral("platform_id")) == false) {
        return ValidationResult::Failed;
    }

    const rapidjson::Value& payload = json[JSON_NOTIFICATION][JSON_PAYLOAD];
    QVector<const char*> jsonPath({JSON_NOTIFICATION, JSON_PAYLOAD});  // successfuly checked JSON path

    // check "controller_type"
    if (checkKey(payload, JSON_CONTROLLER_TYPE, KeyType::Integer, jsonPath) == false) {
        return ValidationResult::Failed;
    }

    // check "platform_id"
    if (checkKey(payload, JSON_PLATFORM_ID, KeyType::String, jsonPath) == false) {
        return ValidationResult::Failed;
    }

    // check "class_id"
    if (checkKey(payload, JSON_CLASS_ID, KeyType::String, jsonPath) == false) {
        return ValidationResult::Failed;
    }

    // check "board_count"
    if (checkKey(payload, JSON_BOARD_COUNT, KeyType::Unsigned64, jsonPath) == false) {
        return ValidationResult::Failed;
    }

    const QString notCorrect(QStringLiteral(" is not set correctly"));
    {  // check values of "platform_id" and "class_id"
        const std::array<const char*, 2> ids = {JSON_PLATFORM_ID, JSON_CLASS_ID};
        for (size_t i = 0; i < ids.size(); ++i) {
            const rapidjson::Value& id = payload[ids[i]];
            const QLatin1String idStr(id.GetString(), id.GetStringLength());
            if (unsetId) {
                if (idStr.isEmpty() == false) {
                    QString message = ids[i] + QStringLiteral(" is already set");
                    qCWarning(lcPlatformValidation) << platform_ << message;
                    emit validationStatus(Status::Error, message);
                    return ValidationResult::Failed;
                }
            } else {
                if (idStr != fakeUuid4_) {
                    QString message = ids[i] + notCorrect;
                    qCWarning(lcPlatformValidation) << platform_ << message;
                    emit validationStatus(Status::Error, message);
                    return ValidationResult::Failed;
                }
            }
        }
    }

    const int controller = payload[JSON_CONTROLLER_TYPE].GetInt();
    const quint64 boardCount = payload[JSON_BOARD_COUNT].GetUint64();

    if (unsetId) {
        if ((controller != CONTROLLER_TYPE_UNSET) && (controller != CONTROLLER_TYPE_EMBEDDED)) {
            QString message = JSON_CONTROLLER_TYPE + (QStringLiteral(" already set to unexpected value"));
            qCWarning(lcPlatformValidation) << platform_ << message;
            emit validationStatus(Status::Error, message);
            return ValidationResult::Failed;
        }
    } else {
        if (controller != CONTROLLER_TYPE_EMBEDDED) {
            QString message = JSON_CONTROLLER_TYPE + notCorrect;
            qCWarning(lcPlatformValidation) << platform_ << message;
            emit validationStatus(Status::Error, message);
            return ValidationResult::Failed;
        }
        if (boardCount != fakeBoardCount_) {
            QString message = JSON_BOARD_COUNT + notCorrect;
            qCWarning(lcPlatformValidation) << platform_ << message;
            emit validationStatus(Status::Error, message);
            return ValidationResult::Failed;
        }
    }

    return ValidationResult::Passed;
}

void EmbeddedRegistration::beforeStartBootloader()
{
    ignoreCmdRejected_ = true;
}

void EmbeddedRegistration::afterStartBootloader(command::CommandResult& result, int& status)
{
    Q_UNUSED(status)

    ignoreCmdRejected_ = false;

    if (result == command::CommandResult::Reject) {
        result = command::CommandResult::Done;
        QString message(QStringLiteral("Platform probably already in bootloader"));
        qCInfo(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Info, message);
    }
}

BaseValidation::ValidationResult EmbeddedRegistration::setPlatformIdCheck(bool expectFailure, bool assisted)
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
        bool badValue = true;
        const rapidjson::Value& status = payload[JSON_STATUS];
        const QLatin1String statusStr(status.GetString(), status.GetStringLength());
        if (expectFailure) {
            if ((statusStr == JSON_FAILED) || (statusStr == JSON_ALREADY_INITIALIZED) || (statusStr == JSON_NOT_SUPPORTED)) {
                badValue = false;
            }
            if (assisted && (statusStr == JSON_BOARD_NOT_CONNECTED)) {
                badValue = false;
            }
        } else {
            if (statusStr == JSON_OK) {
                badValue = false;
            }
        }
        if (badValue) {
            QString message = unsupportedValue(joinKeys(jsonPath, JSON_STATUS), statusStr, true);
            qCWarning(lcPlatformValidation) << platform_ << message;
            emit validationStatus(Status::Error, message);
            return ValidationResult::Failed;
        }
    }

    return ValidationResult::Passed;
}

void EmbeddedRegistration::beforeSetIdFailure()
{
    ignoreFaultyNotification_ = true;
}

void EmbeddedRegistration::afterSetIdFailure(command::CommandResult& result, int& status)
{
    ignoreFaultyNotification_ = false;

    if (result == command::CommandResult::Failure) {
        result = command::CommandResult::Done;
        QString message = QStringLiteral("Expected failure of ") + currentCommand_->command->name();
        if (status == operation::PLATFORM_ID_ALREADY_SET) {
            message += QStringLiteral(" - ID already set");
        } else if (status == operation::COMMAND_NOT_SUPPORTED) {
            message += QStringLiteral(" - command not supported");
        }
        qCInfo(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Info, message);
    }
}

void EmbeddedRegistration::afterStartApplication(command::CommandResult& result, int& status)
{
    if ((result == command::CommandResult::FinaliseOperation) && (status == operation::NO_FIRMWARE)) {
        result = command::CommandResult::Done;
        QString message(QStringLiteral("No application present at platform"));
        qCInfo(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Warning, message);
    }
}

}  // namespace
