/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <Operations/PlatformValidation/Identification.h>
#include <Commands/PlatformCommands.h>
#include <Commands/PlatformCommandConstants.h>

#include "logging/LoggingQtCategories.h"

#include <QLatin1String>

#include <array>

namespace strata::platform::validation {

Identification::Identification(const PlatformPtr& platform)
    : BaseValidation(platform, Type::Identification, QStringLiteral("Identification"))
{
    commandList_.reserve(2);

    // BaseValidation member platform_ must be used as a parameter for commands!
    commandList_.emplace_back(std::make_unique<command::CmdGetFirmwareInfo>(platform_, true, 0),
                              nullptr,
                              nullptr,
                              std::bind(&Identification::getFirmwareInfoCheck, this));
    commandList_.emplace_back(std::make_unique<command::CmdRequestPlatformId>(platform_),
                              nullptr,
                              nullptr,
                              std::bind(&Identification::requestPlatformIdCheck, this));
}

BaseValidation::ValidationResult Identification::getFirmwareInfoCheck()
{
    using namespace strata::platform::command;

    const rapidjson::Document& json = lastPlatformNotification_.json();

    if (generalNotificationCheck(json, currentCommand_->command->name()) == false) {
        return ValidationResult::Failed;
    }

    const rapidjson::Value& payload = json[JSON_NOTIFICATION][JSON_PAYLOAD];
    QVector<const char*> jsonPath({JSON_NOTIFICATION, JSON_PAYLOAD});  // successfuly checked JSON path

    // check "api_version"
    if (payload.HasMember(JSON_API_VERSION)) {
        if (checkKey(payload, JSON_API_VERSION, KeyType::String, jsonPath) == false) {
            return ValidationResult::Failed;
        }
        if (platform_->apiVersion() != Platform::ApiVersion::v2_0) {
            QString message = QStringLiteral("Unknown API version: '") + payload[JSON_API_VERSION].GetString() + '\'';
            qCInfo(lcPlatformValidation) << platform_ << message;
            emit validationStatus(Status::Info, message);
        }
    } else {  // API v1
        QString message = missingKey(joinKeys(jsonPath, JSON_API_VERSION)) + QStringLiteral(" - legacy API version 1");
        qCWarning(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Warning, message);
        return ValidationResult::Incomplete;
    }

    bool inBootloader = false;
    {  // check "active"
        if (checkKey(payload, JSON_ACTIVE, KeyType::String, jsonPath) == false) {
            return ValidationResult::Failed;
        }
        const rapidjson::Value& active = payload[JSON_ACTIVE];
        QLatin1String activeStr(active.GetString(), active.GetStringLength());
        if (activeStr == CSTR_BOOTLOADER) {
            inBootloader = true;
        } else if (activeStr != CSTR_APPLICATION) {
            QString message = unsupportedValue(joinKeys(jsonPath, JSON_ACTIVE), activeStr);
            qCWarning(lcPlatformValidation) << platform_ << message;
            emit validationStatus(Status::Error, message);
            return ValidationResult::Failed;
        }
    }

    {  // check "bootloader"
        if (checkKey(payload, JSON_BOOTLOADER, KeyType::Object, jsonPath) == false) {
            return ValidationResult::Failed;
        }

        jsonPath.append(JSON_BOOTLOADER);
        const rapidjson::Value& bootloader = payload[JSON_BOOTLOADER];

        // check "version" and "date"
        const QVector<const char*> keys({JSON_VERSION, JSON_DATE});
        for (auto key : keys) {
            if (checkKey(bootloader, key, KeyType::String, jsonPath) == false) {
                return ValidationResult::Failed;
            }
            const rapidjson::Value& value = bootloader[key];
            QLatin1String valueStr(value.GetString(), value.GetStringLength());
            if (valueStr.isEmpty()) {
                QString message = unsupportedValue(joinKeys(jsonPath, key), valueStr);
                qCWarning(lcPlatformValidation) << platform_ << message;
                emit validationStatus(Status::Warning, message);
            }
        }

        jsonPath.removeLast();  // remove JSON_BOOTLOADER from path
    }

    {  // check "application"
        if (checkKey(payload, JSON_APPLICATION, KeyType::Object, jsonPath) == false) {
            return ValidationResult::Failed;
        }

        jsonPath.append(JSON_APPLICATION);
        const rapidjson::Value& application = payload[JSON_APPLICATION];

        // check "version" and "date"
        const QVector<const char*> keys({JSON_VERSION, JSON_DATE});
        for (auto key : keys) {
            if (checkKey(application, key, KeyType::String, jsonPath) == false) {
                return ValidationResult::Failed;
            }
            if (inBootloader == false) {  // value can be empty if only bootloader is flashed on platform
                const rapidjson::Value& value = application[key];
                QLatin1String valueStr(value.GetString(), value.GetStringLength());
                if (valueStr.isEmpty()) {
                    QString message = unsupportedValue(joinKeys(jsonPath, key), valueStr);
                    qCWarning(lcPlatformValidation) << platform_ << message;
                    emit validationStatus(Status::Warning, message);
                }
            }
        }

        jsonPath.removeLast();  // remove JSON_APPLICATION from path
    }

    {
        QString message = currentCommand_->command->name() + QStringLiteral(" OK");
        qCInfo(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Success, message);
    }
    return ValidationResult::Passed;
}

BaseValidation::ValidationResult Identification::requestPlatformIdCheck()
{
    using namespace strata::platform::command;

    const rapidjson::Document& json = lastPlatformNotification_.json();

    if (generalNotificationCheck(json, QStringLiteral("platform_id")) == false) {
        return ValidationResult::Failed;
    }

    const rapidjson::Value& payload = json[JSON_NOTIFICATION][JSON_PAYLOAD];
    QVector<const char*> jsonPath({JSON_NOTIFICATION, JSON_PAYLOAD});  // successfuly checked JSON path

    // check "name"
    if (checkKey(payload, JSON_NAME, KeyType::String, jsonPath) == false) {
        return ValidationResult::Failed;
    }

    constexpr quint64 EMBEDDED = static_cast<quint64>(CONTROLLER_TYPE_EMBEDDED);
    constexpr quint64 ASSISTED = static_cast<quint64>(CONTROLLER_TYPE_ASSISTED);
    quint64 controller;
    {  // check "controller_type"
        if (checkKey(payload, JSON_CONTROLLER_TYPE, KeyType::Unsigned, jsonPath) == false) {
            return ValidationResult::Failed;
        }
        controller = payload[JSON_CONTROLLER_TYPE].GetUint64();
        if (controller == 0) {
            QString message = JSON_CONTROLLER_TYPE + QStringLiteral(" not set, continuing as EMBEDDED");
            qCWarning(lcPlatformValidation) << platform_ << message;
            emit validationStatus(Status::Warning, message);
            controller = EMBEDDED;
        }
        if ((controller != EMBEDDED) && (controller != ASSISTED)) {
            QString message = unsupportedValue(joinKeys(jsonPath, JSON_CONTROLLER_TYPE), QString::number(controller));
            qCWarning(lcPlatformValidation) << platform_ << message;
            emit validationStatus(Status::Error, message);
            return ValidationResult::Failed;
        }
        QString message = (controller == EMBEDDED) ? QStringLiteral("Recognized embedded board") : QStringLiteral("Recognized assisted controller");
        qCInfo(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Info, message);
    }

    {  // check "platform_id", "class_id", "board_count", "controller_platform_id",
       // "controller_class_id", "controller_board_count", "fw_class_id"
        struct KeyInfo {
            const char* key;
            KeyType type;
            bool present;
        };
        // keys for embedded board and for complete assisted (dongle + platfom) board
        std::array<KeyInfo, 3> keysBoth = {{
            {JSON_PLATFORM_ID, KeyType::String,   false},
            {JSON_CLASS_ID,    KeyType::String,   false},
            {JSON_BOARD_COUNT, KeyType::Unsigned, false}
        }};
        // keys for assisted board (with or without dongle)
        std::array<KeyInfo, 4> keysAssist = {{
            {JSON_CNTRL_PLATFORM_ID, KeyType::String,   false},
            {JSON_CNTRL_CLASS_ID,    KeyType::String,   false},
            {JSON_CNTRL_BOARD_COUNT, KeyType::Unsigned, false},
            {JSON_FW_CLASS_ID,       KeyType::String,   false}
        }};
        unsigned int keysBothCount = 0;
        for (size_t i = 0; i < keysBoth.size(); ++i) {
            if (payload.HasMember(keysBoth[i].key)) {
                keysBoth[i].present = true;
                ++keysBothCount;
            }
        }
        for (size_t i = 0; i < keysAssist.size(); ++i) {
            if (payload.HasMember(keysAssist[i].key)) {
                keysAssist[i].present = true;
            }
        }
        // keys mandatory for embedded and complete assisted (dongle + platfom)
        if ( (controller == EMBEDDED) || (keysBothCount > 0) ) {
            for (size_t i = 0; i < keysBoth.size(); ++i) {
                if (checkKey(payload, keysBoth[i].key, keysBoth[i].type, jsonPath) == false) {
                    return ValidationResult::Failed;
                }
            }
        }
        // keys mandatory for assisted
        if (controller == ASSISTED) {
            if (keysBothCount == 0) {  // only dongle connected
                QString message = QStringLiteral("Assisted board not connected");
                qCInfo(lcPlatformValidation) << platform_ << message;
                emit validationStatus(Status::Info, message);
            }
            for (size_t i = 0; i < keysAssist.size(); ++i) {
                if (checkKey(payload, keysAssist[i].key, keysAssist[i].type, jsonPath) == false) {
                    return ValidationResult::Failed;
                }
            }
        }
        // check if there are some assisted keys for embedded platform
        if (controller == EMBEDDED) {
            for (size_t i = 0; i < keysAssist.size(); ++i) {
                if (keysAssist[i].present) {
                    QString message = QStringLiteral("Unexpected key '") + joinKeys(jsonPath, keysAssist[i].key) + '\'';
                    qCWarning(lcPlatformValidation) << platform_ << message;
                    emit validationStatus(Status::Error, message);
                    return ValidationResult::Failed;
                }
            }
        }
    }

    {
        QString message = currentCommand_->command->name() + QStringLiteral(" OK");
        qCInfo(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Success, message);
    }
    return ValidationResult::Passed;
}

}  // namespace
