/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "EmbeddedRegistration.h"
#include "ValidationStatus.h"
#include "logging/LoggingQtCategories.h"

#include <PlatformCommands.h>
#include <PlatformCommandConstants.h>
#include <PlatformOperationsStatus.h>

#include <QLatin1String>

#include <array>
#include <iterator>

namespace strata::platform::validation {

EmbeddedRegistration::EmbeddedRegistration(const PlatformPtr& platform, const QString& name)
    : BaseValidation(platform, name)
{
    data_.classId = QStringLiteral("00000000-0000-4000-8000-100000000000");
    data_.platformId = QStringLiteral("00000000-0000-4000-8000-200000000000");
    data_.boardCount = 3210;

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

    // Set class ID + platform ID.
    commandList_.emplace_back(std::make_unique<command::CmdSetPlatformId>(platform_, data_),
                              nullptr,
                              nullptr,
                              std::bind(&EmbeddedRegistration::setPlatformIdCheck, this, false, false));

    // This command is expected to fail. Set class ID + platform ID.
    commandList_.emplace_back(std::make_unique<command::CmdSetPlatformId>(platform_, data_),
                              std::bind(&EmbeddedRegistration::beforeSetIdFailure, this),
                              std::bind(&EmbeddedRegistration::afterSetIdFailure, this, std::placeholders::_1, std::placeholders::_2),
                              std::bind(&EmbeddedRegistration::setPlatformIdCheck, this, true, false));

    {  // This command is expected to fail. Set class ID + platform ID + controller class ID + controller platform ID + FW class ID
        std::unique_ptr<command::CmdSetAssistedPlatformId> cmdSetAssistPlatfId = std::make_unique<command::CmdSetAssistedPlatformId>(platform_);
        cmdSetAssistPlatfId->setAckTimeout(std::chrono::milliseconds(2000));  // special case, firmware takes too long to send ACK (see CS-1722)
        cmdSetAssistPlatfId->setBaseData(data_);
        cmdSetAssistPlatfId->setControllerData(data_);
        cmdSetAssistPlatfId->setFwClassId(data_.classId);
        commandList_.emplace_back(std::move(cmdSetAssistPlatfId),
                                  std::bind(&EmbeddedRegistration::beforeSetIdFailure, this),
                                  std::bind(&EmbeddedRegistration::afterSetIdFailure, this, std::placeholders::_1, std::placeholders::_2),
                                  std::bind(&EmbeddedRegistration::setPlatformIdCheck, this, true, true));
    }

    commandList_.emplace_back(std::make_unique<command::CmdStartApplication>(platform_),
                              nullptr,
                              std::bind(&EmbeddedRegistration::afterStartApplication, this, std::placeholders::_1, std::placeholders::_2),
                              nullptr);

    // If application cannot start, next 3 commands are skipped.

    commandList_.emplace_back(std::make_unique<command::CmdWait>(platform_, std::chrono::milliseconds(500), QStringLiteral("Waiting for application to start")),
                              nullptr,
                              nullptr,
                              nullptr);

    // This command is expected to fail. Set class ID + platform ID.
    commandList_.emplace_back(std::make_unique<command::CmdSetPlatformId>(platform_, data_),
                              std::bind(&EmbeddedRegistration::beforeSetIdFailure, this),
                              std::bind(&EmbeddedRegistration::afterSetIdFailure, this, std::placeholders::_1, std::placeholders::_2),
                              std::bind(&EmbeddedRegistration::setPlatformIdCheck, this, true, false));

    {  // This command is expected to fail. Set class ID + platform ID + controller class ID + controller platform ID + FW class ID
        std::unique_ptr<command::CmdSetAssistedPlatformId> cmdSetAssistPlatfId = std::make_unique<command::CmdSetAssistedPlatformId>(platform_);
        cmdSetAssistPlatfId->setAckTimeout(std::chrono::milliseconds(2000));  // special case, firmware takes too long to send ACK (see CS-1722)
        cmdSetAssistPlatfId->setBaseData(data_);
        cmdSetAssistPlatfId->setControllerData(data_);
        cmdSetAssistPlatfId->setFwClassId(data_.classId);
        commandList_.emplace_back(std::move(cmdSetAssistPlatfId),
                                  std::bind(&EmbeddedRegistration::beforeSetIdFailure, this),
                                  std::bind(&EmbeddedRegistration::afterSetIdFailure, this, std::placeholders::_1, std::placeholders::_2),
                                  std::bind(&EmbeddedRegistration::setPlatformIdCheck, this, true, true));
    }

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

    if (checkKey(payload, JSON_CONTROLLER_TYPE, KeyType::Integer, jsonPath) == false) {
        return ValidationResult::Failed;
    }
    const int controller = payload[JSON_CONTROLLER_TYPE].GetInt();

    if (controller == CONTROLLER_TYPE_ASSISTED) {
        QString message(QStringLiteral("Platform recognized as assisted"));
        qCWarning(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Warning, message);
    }

    if (checkKey(payload, JSON_PLATFORM_ID, KeyType::String, jsonPath) == false) {
        return ValidationResult::Failed;
    }
    const rapidjson::Value& platformId = payload[JSON_PLATFORM_ID];
    const QLatin1String platformIdStr(platformId.GetString(), platformId.GetStringLength());

    if (checkKey(payload, JSON_CLASS_ID, KeyType::String, jsonPath) == false) {
        return ValidationResult::Failed;
    }
    const rapidjson::Value& classId = payload[JSON_CLASS_ID];
    const QLatin1String classIdStr(classId.GetString(), classId.GetStringLength());

    if (checkKey(payload, JSON_BOARD_COUNT, KeyType::Unsigned64, jsonPath) == false) {
        return ValidationResult::Failed;
    }
    const quint64 boardCount = payload[JSON_BOARD_COUNT].GetUint64();

    if (unsetId) {
        // check "controller_type"
        if ((controller != CONTROLLER_TYPE_UNSET) && (controller != CONTROLLER_TYPE_EMBEDDED)) {
            QString message = JSON_CONTROLLER_TYPE + (QStringLiteral(" already set to unexpected value"));
            qCWarning(lcPlatformValidation) << platform_ << message;
            emit validationStatus(Status::Error, message);
            return ValidationResult::Failed;
        }
        // check "platform_id", "class_id"
        struct KeyInfo {
            const char* key;
            const QLatin1String& value;
        };
        std::array<KeyInfo, 2> keys = {{
            {JSON_PLATFORM_ID, platformIdStr},
            {JSON_CLASS_ID,    classIdStr}
        }};
        for (size_t i = 0; i < keys.size(); ++i) {
            if (keys[i].value.isEmpty() == false) {
                QString message = keys[i].key + QStringLiteral(" is already set");
                qCWarning(lcPlatformValidation) << platform_ << message;
                emit validationStatus(Status::Warning, message);
                return ValidationResult::Incomplete;
            }
        }
    } else {
        // check "controller_type"
        if (controller != CONTROLLER_TYPE_EMBEDDED) {
            logAndEmitUnexpectedValue(jsonPath, JSON_CONTROLLER_TYPE, QString::number(controller), QString::number(CONTROLLER_TYPE_EMBEDDED));
            return ValidationResult::Failed;
        }
        // check "platform_id"
        if (platformIdStr != data_.platformId) {
            logAndEmitUnexpectedValue(jsonPath, JSON_PLATFORM_ID, platformIdStr, data_.platformId);
            return ValidationResult::Failed;
        }
        // check "class_id"
        if (classIdStr != data_.classId) {
            logAndEmitUnexpectedValue(jsonPath, JSON_CLASS_ID, classIdStr, data_.classId);
            return ValidationResult::Failed;
        }
        // check "board_count"
        if (boardCount != static_cast<quint64>(data_.boardCount)) {
            logAndEmitUnexpectedValue(jsonPath, JSON_BOARD_COUNT, QString::number(boardCount), QString::number(data_.boardCount));
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
            if (expectFailure) {
                message += QStringLiteral(" - repeated registration should fail");
            }
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
        emit validationStatus(Status::Success, message);
    }
}

void EmbeddedRegistration::afterStartApplication(command::CommandResult& result, int& status)
{
    if ((result == command::CommandResult::FinaliseOperation) && (status == operation::NO_FIRMWARE)) {
        result = command::CommandResult::Done;
        QString message(QStringLiteral("No application present at platform"));
        qCInfo(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Warning, message);
        // skip commands which should test application (they are added in constructor)
        for (int i = 0; i < 3; ++i) {
            skipNextCommand();
        }
    }
}

void EmbeddedRegistration::skipNextCommand()
{
    // if current command is not last, skip next command
    if (std::distance(currentCommand_, commandList_.end()) > 1) {
        ++currentCommand_;
    }
}

void EmbeddedRegistration::logAndEmitUnexpectedValue(const QVector<const char *> &path,
                                                     const char *key,
                                                     const QString& current,
                                                     const QString& expected)
{
    QString message = unsupportedValue(joinKeys(path, key), current, true)
                  + QStringLiteral(" Expected '") + expected + '\'';
    qCWarning(lcPlatformValidation) << platform_ << message;
    emit validationStatus(Status::Error, message);
}

}  // namespace
