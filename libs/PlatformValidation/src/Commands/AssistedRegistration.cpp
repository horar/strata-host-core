/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "AssistedRegistration.h"
#include "ValidationStatus.h"
#include "logging/LoggingQtCategories.h"

#include <PlatformCommands.h>
#include <PlatformCommandConstants.h>
#include <PlatformOperationsStatus.h>
#include <PlatformOperationsData.h>

#include <QLatin1String>

#include <array>
#include <iterator>

namespace strata::platform::validation {

AssistedRegistration::AssistedRegistration(const PlatformPtr& platform, const QString& name)
    : BaseValidation(platform, name),
      assistedBoardConnected_(false)
{
    data_.classId = QStringLiteral("00000000-0000-4000-8000-000000000001");
    data_.platformId = QStringLiteral("00000000-0000-4000-8000-000000000002");
    data_.boardCount = 1230;
    controllerData_.classId = QStringLiteral("00000000-0000-4000-8000-000000000003");
    controllerData_.platformId = QStringLiteral("00000000-0000-4000-8000-000000000004");
    controllerData_.boardCount = 4560;
    fwClassId1_ = QStringLiteral("00000000-0000-4000-8000-000000000005");
    fwClassId2_ = QStringLiteral("00000000-0000-4000-8000-000000000006");

    commandList_.reserve(14);

    // BaseValidation member platform_ must be used as a parameter for commands!

    commandList_.emplace_back(std::make_unique<command::CmdRequestPlatformId>(platform_),
                              nullptr,
                              nullptr,
                              std::bind(&AssistedRegistration::requestPlatformIdCheck, this, true));

    commandList_.emplace_back(std::make_unique<command::CmdStartBootloader>(platform_),
                              std::bind(&AssistedRegistration::beforeStartBootloader, this),
                              std::bind(&AssistedRegistration::afterStartBootloader, this, std::placeholders::_1, std::placeholders::_2),
                              nullptr);

    commandList_.emplace_back(std::make_unique<command::CmdWait>(platform_, std::chrono::milliseconds(500), QStringLiteral("Waiting for bootloader to start")),
                              nullptr,
                              nullptr,
                              nullptr);

    {  // Set controller class ID + controller platform ID.
        std::unique_ptr<command::CmdSetAssistedPlatformId> cmdSetAssistPlatfId = std::make_unique<command::CmdSetAssistedPlatformId>(platform_);
        cmdSetAssistPlatfId->setAckTimeout(std::chrono::milliseconds(2000));  // special case, firmware takes too long to send ACK (see CS-1722)
        cmdSetAssistPlatfId->setControllerData(controllerData_);
        commandList_.emplace_back(std::move(cmdSetAssistPlatfId),
                                  nullptr,
                                  nullptr,
                                  std::bind(&AssistedRegistration::setPlatformIdCheck, this, false, true));
    }

    {  // This command is expected to fail. Set controller class ID + controller platform ID.
        std::unique_ptr<command::CmdSetAssistedPlatformId> cmdSetAssistPlatfId = std::make_unique<command::CmdSetAssistedPlatformId>(platform_);
        cmdSetAssistPlatfId->setAckTimeout(std::chrono::milliseconds(2000));  // special case, firmware takes too long to send ACK (see CS-1722)
        cmdSetAssistPlatfId->setControllerData(controllerData_);
        commandList_.emplace_back(std::move(cmdSetAssistPlatfId),
                                  std::bind(&AssistedRegistration::beforeSetIdFailure, this),
                                  std::bind(&AssistedRegistration::afterSetIdFailure, this, std::placeholders::_1, std::placeholders::_2),
                                  std::bind(&AssistedRegistration::setPlatformIdCheck, this, true, true));
    }

    commandList_.emplace_back(std::make_unique<command::CmdRequestPlatformId>(platform_),
                              nullptr,
                              std::bind(&AssistedRegistration::afterAssistedConnectedCheck, this, std::placeholders::_1, std::placeholders::_2),
                              nullptr);

    {  // This command will be skipped if assited board is not connected. Set class ID + platform ID.
        std::unique_ptr<command::CmdSetAssistedPlatformId> cmdSetAssistPlatfId = std::make_unique<command::CmdSetAssistedPlatformId>(platform_);
        cmdSetAssistPlatfId->setAckTimeout(std::chrono::milliseconds(2000));  // special case, firmware takes too long to send ACK (see CS-1722)
        cmdSetAssistPlatfId->setBaseData(data_);
        commandList_.emplace_back(std::move(cmdSetAssistPlatfId),
                                  nullptr,
                                  nullptr,
                                  std::bind(&AssistedRegistration::setPlatformIdCheck, this, false, true));
    }

    {  // This command is expected to fail. Set class ID + platform ID.
        std::unique_ptr<command::CmdSetAssistedPlatformId> cmdSetAssistPlatfId = std::make_unique<command::CmdSetAssistedPlatformId>(platform_);
        cmdSetAssistPlatfId->setAckTimeout(std::chrono::milliseconds(2000));  // special case, firmware takes too long to send ACK (see CS-1722)
        cmdSetAssistPlatfId->setBaseData(data_);
        commandList_.emplace_back(std::move(cmdSetAssistPlatfId),
                                  std::bind(&AssistedRegistration::beforeSetIdFailure, this),
                                  std::bind(&AssistedRegistration::afterSetIdFailure, this, std::placeholders::_1, std::placeholders::_2),
                                  std::bind(&AssistedRegistration::setPlatformIdCheck, this, true, true));
    }

    {  // Set FW class ID 1.
        std::unique_ptr<command::CmdSetAssistedPlatformId> cmdSetAssistPlatfId = std::make_unique<command::CmdSetAssistedPlatformId>(platform_);
        cmdSetAssistPlatfId->setAckTimeout(std::chrono::milliseconds(2000));  // special case, firmware takes too long to send ACK (see CS-1722)
        cmdSetAssistPlatfId->setFwClassId(fwClassId1_);
        commandList_.emplace_back(std::move(cmdSetAssistPlatfId),
                                  nullptr,
                                  nullptr,
                                  std::bind(&AssistedRegistration::setPlatformIdCheck, this, false, true));
    }

    {  // Set FW class ID 2.
        std::unique_ptr<command::CmdSetAssistedPlatformId> cmdSetAssistPlatfId = std::make_unique<command::CmdSetAssistedPlatformId>(platform_);
        cmdSetAssistPlatfId->setAckTimeout(std::chrono::milliseconds(2000));  // special case, firmware takes too long to send ACK (see CS-1722)
        cmdSetAssistPlatfId->setFwClassId(fwClassId2_);
        commandList_.emplace_back(std::move(cmdSetAssistPlatfId),
                                  nullptr,
                                  nullptr,
                                  std::bind(&AssistedRegistration::setPlatformIdCheck, this, false, true));
    }

    // This command is expected to fail.
    commandList_.emplace_back(std::make_unique<command::CmdSetPlatformId>(platform_, data_),
                              std::bind(&AssistedRegistration::beforeSetIdFailure, this),
                              std::bind(&AssistedRegistration::afterSetIdFailure, this, std::placeholders::_1, std::placeholders::_2),
                              std::bind(&AssistedRegistration::setPlatformIdCheck, this, true, false));

    commandList_.emplace_back(std::make_unique<command::CmdStartApplication>(platform_),
                              nullptr,
                              std::bind(&AssistedRegistration::afterStartApplication, this, std::placeholders::_1, std::placeholders::_2),
                              nullptr);

    commandList_.emplace_back(std::make_unique<command::CmdWait>(platform_, std::chrono::milliseconds(500), QStringLiteral("Waiting for application to start")),
                              nullptr,
                              nullptr,
                              nullptr);

    commandList_.emplace_back(std::make_unique<command::CmdRequestPlatformId>(platform_),
                              nullptr,
                              nullptr,
                              std::bind(&AssistedRegistration::requestPlatformIdCheck, this, false));
}

BaseValidation::ValidationResult AssistedRegistration::requestPlatformIdCheck(bool unsetId)
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

    if (unsetId) {
        // check "class_id", "platform_id", "controller_class_id", "controller_platform_id"
        const std::array<const char*, 4> ids = {JSON_PLATFORM_ID, JSON_CLASS_ID, JSON_CNTRL_PLATFORM_ID, JSON_CNTRL_CLASS_ID};
        for (size_t i = 0; i < ids.size(); ++i) {
            const char* key = ids[i];
            if (payload.HasMember(key)) {
                if (checkKey(payload, key, KeyType::String, jsonPath) == false) {
                    return ValidationResult::Failed;
                }
                const rapidjson::Value& id = payload[key];
                const QLatin1String idStr(id.GetString(), id.GetStringLength());
                if (idStr.isEmpty() == false) {
                    QString message = key + QStringLiteral(" is already set");
                    qCWarning(lcPlatformValidation) << platform_ << message;
                    emit validationStatus(Status::Warning, message);
                    return ValidationResult::Incomplete;
                }
            }
        }
    } else {
        // check "controller_type"
        const int controller = payload[JSON_CONTROLLER_TYPE].GetInt();
        if (controller != CONTROLLER_TYPE_ASSISTED) {
            QString message = unsupportedValue(joinKeys(jsonPath, JSON_STATUS), QString::number(controller), true);
            qCWarning(lcPlatformValidation) << platform_ << message;
            emit validationStatus(Status::Error, message);
            return ValidationResult::Failed;
        }

        // check strings "class_id", "platform_id", "controller_class_id", "controller_platform_id", "fw_class_id"
        struct KeyInfoStr {
            const char* key;
            bool required;
            const QString& value;
        };
        std::array<KeyInfoStr, 5> keysStr = {{
            {JSON_PLATFORM_ID, assistedBoardConnected_, data_.platformId},
            {JSON_CLASS_ID,    assistedBoardConnected_, data_.classId},
            {JSON_CNTRL_PLATFORM_ID, true, controllerData_.platformId},
            {JSON_CNTRL_CLASS_ID,    true, controllerData_.classId},
            {JSON_FW_CLASS_ID,       true, fwClassId2_}
        }};
        for (size_t i = 0; i < keysStr.size(); ++i) {
            if (keysStr[i].required) {
                const char* key = keysStr[i].key;
                if (checkKey(payload, key, KeyType::String, jsonPath) == false) {
                    return ValidationResult::Failed;
                }
                const rapidjson::Value& id = payload[key];
                const QLatin1String idStr(id.GetString(), id.GetStringLength());
                if (idStr != keysStr[i].value) {
                    QString message = unsupportedValue(joinKeys(jsonPath, key), idStr, true)
                                      + QStringLiteral(" Expected '") + keysStr[i].value + '\'';
                    qCWarning(lcPlatformValidation) << platform_ << message;
                    emit validationStatus(Status::Error, message);
                    return ValidationResult::Failed;
                }
            }
        }

        // check unsigneds "board_count", "controller_board_count"
        struct KeyInfoUint64 {
            const char* key;
            bool required;
            quint64 count;
        };
        std::array<KeyInfoUint64, 2> keysUint64 = {{
            {JSON_BOARD_COUNT, assistedBoardConnected_, static_cast<quint64>(data_.boardCount)},
            {JSON_CNTRL_BOARD_COUNT, true, static_cast<quint64>(controllerData_.boardCount)}
        }};
        for (size_t i = 0; i < keysUint64.size(); ++i) {
            if (keysUint64[i].required) {
                const char* key = keysUint64[i].key;
                if (checkKey(payload, key, KeyType::Unsigned64, jsonPath) == false) {
                    return ValidationResult::Failed;
                }
                const quint64 count = payload[key].GetUint64();
                if (count != keysUint64[i].count) {
                    QString message = unsupportedValue(joinKeys(jsonPath, key), QString::number(count), true)
                                      + QStringLiteral(" Expected '") + QString::number(keysUint64[i].count) + '\'';
                    qCWarning(lcPlatformValidation) << platform_ << message;
                    emit validationStatus(Status::Error, message);
                    return ValidationResult::Failed;
                }
            }
        }
    }

    return ValidationResult::Passed;
}

void AssistedRegistration::beforeStartBootloader()
{
    ignoreCmdRejected_ = true;
}

void AssistedRegistration::afterStartBootloader(command::CommandResult& result, int& status)
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

BaseValidation::ValidationResult AssistedRegistration::setPlatformIdCheck(bool expectFailure, bool assisted)
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

void AssistedRegistration::beforeSetIdFailure()
{
    ignoreFaultyNotification_ = true;
}

void AssistedRegistration::afterSetIdFailure(command::CommandResult& result, int& status)
{
    ignoreFaultyNotification_ = false;

    if (result == command::CommandResult::Failure) {
        result = command::CommandResult::Done;
        QString message = QStringLiteral("Expected failure of ") + currentCommand_->command->name();
        if (status == operation::PLATFORM_ID_ALREADY_SET) {
            message += QStringLiteral(" - ID already set");
        } else if (status == operation::COMMAND_NOT_SUPPORTED) {
            message += QStringLiteral(" - command not supported");
        } else if (status == operation::BOARD_NOT_CONNECTED_TO_CONTROLLER) {
            message += QStringLiteral(" - platform not connected");
        }
        qCInfo(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Success, message);
    }
}

void AssistedRegistration::afterAssistedConnectedCheck(command::CommandResult& result, int& status)
{
    Q_UNUSED(status)

    if (platform_->isControllerConnectedToPlatform()) {
        assistedBoardConnected_ = true;
    } else {
        assistedBoardConnected_ = false;
        QString message(QStringLiteral("Assisted platform not connected"));
        qCInfo(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Info, message);

        if (result == command::CommandResult::Done) {
            // skip command for setting assisted platform IDs
            skipNextCommand();
        }
    }
}

void AssistedRegistration::afterStartApplication(command::CommandResult& result, int& status)
{
    if ((result == command::CommandResult::FinaliseOperation) && (status == operation::NO_FIRMWARE)) {
        result = command::CommandResult::Done;
        QString message(QStringLiteral("No application present at platform"));
        qCInfo(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Warning, message);
    }
}

void AssistedRegistration::skipNextCommand()
{
    // if current command is not last, skip next command
    if (std::distance(currentCommand_, commandList_.end()) > 1) {
        ++currentCommand_;
        QString message = QStringLiteral("Skipping command '") + currentCommand_->command->name() + '\'';
        qCInfo(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Info, message);
    }
}

}  // namespace
