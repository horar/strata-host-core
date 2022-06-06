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

#include <QLatin1String>

#include <array>

namespace strata::platform::validation {

Identification::Identification(const PlatformPtr& platform)
    : BaseValidation(platform, Type::Identification)
{
    commandList_.reserve(2);

    // BaseValidation member platform_ must be used as a parameter for commands!
    commandList_.emplace_back(std::make_unique<command::CmdGetFirmwareInfo>(platform_, true, 0),
                              std::bind(&Identification::getFirmwareInfoCheck, this));
    commandList_.emplace_back(std::make_unique<command::CmdRequestPlatformId>(platform_),
                              std::bind(&Identification::requestPlatformIdCheck, this));
}

bool Identification::getFirmwareInfoCheck()
{
    using namespace strata::platform::command;

    const rapidjson::Document& json = lastPlatformNotification_.json();

    if (generalNotificationCheck(json, currentCommand_->command->name()) == false) {
        return false;
    }

    const rapidjson::Value& payload = json[JSON_NOTIFICATION][JSON_PAYLOAD];
    QVector<const char*> jsonPath({JSON_NOTIFICATION, JSON_PAYLOAD});  // successfuly checked JSON path

    // check "api_version"
    if (checkKey(payload, JSON_API_VERSION, KeyType::String, jsonPath) == false) {
         return false;
    }
    if (platform_->apiVersion() != Platform::ApiVersion::v2_0) {
        emit validationStatus(Status::Info, QStringLiteral("Unknown API version: '") + payload[JSON_API_VERSION].GetString() + QStringLiteral("'."));
    }

    bool inBootloader = false;
    {  // check "active"
        if (checkKey(payload, JSON_ACTIVE, KeyType::String, jsonPath) == false) {
            return false;
        }
        const rapidjson::Value& active = payload[JSON_ACTIVE];
        QLatin1String activeStr(active.GetString(), active.GetStringLength());
        if (activeStr == CSTR_BOOTLOADER) {
            inBootloader = true;
        } else if (activeStr != CSTR_APPLICATION) {
            emit validationStatus(Status::Error, unsupportedValue(joinKeys(jsonPath, JSON_ACTIVE), activeStr));
            return false;
        }
    }

    {  // check "bootloader"
        if (checkKey(payload, JSON_BOOTLOADER, KeyType::Object, jsonPath) == false) {
            return false;
        }

        jsonPath.append(JSON_BOOTLOADER);
        const rapidjson::Value& bootloader = payload[JSON_BOOTLOADER];

        // check "version" and "date"
        const QVector<const char*> keys({JSON_VERSION, JSON_DATE});
        for (auto key : keys) {
            if (checkKey(bootloader, key, KeyType::String, jsonPath) == false) {
                return false;
            }
            const rapidjson::Value& value = bootloader[key];
            QLatin1String valueStr(value.GetString(), value.GetStringLength());
            if (valueStr.isEmpty()) {
                emit validationStatus(Status::Warning, unsupportedValue(joinKeys(jsonPath, key), valueStr));
            }
        }

        jsonPath.removeLast();  // remove JSON_BOOTLOADER from path
    }

    {  // check "application"
        if (checkKey(payload, JSON_APPLICATION, KeyType::Object, jsonPath) == false) {
            return false;
        }

        jsonPath.append(JSON_APPLICATION);
        const rapidjson::Value& application = payload[JSON_APPLICATION];

        // check "version" and "date"
        const QVector<const char*> keys({JSON_VERSION, JSON_DATE});
        for (auto key : keys) {
            if (checkKey(application, key, KeyType::String, jsonPath) == false) {
                return false;
            }
            if (inBootloader == false) {  // value can be empty if only bootloader is flashed on platform
                const rapidjson::Value& value = application[key];
                QLatin1String valueStr(value.GetString(), value.GetStringLength());
                if (valueStr.isEmpty()) {
                    emit validationStatus(Status::Warning, unsupportedValue(joinKeys(jsonPath, key), valueStr));
                }
            }
        }

        jsonPath.removeLast();  // remove JSON_APPLICATION from path
    }

    return true;
}

bool Identification::requestPlatformIdCheck()
{
    using namespace strata::platform::command;

    const rapidjson::Document& json = lastPlatformNotification_.json();

    if (generalNotificationCheck(json, QStringLiteral("platform_id")) == false) {
        return false;
    }

    const rapidjson::Value& payload = json[JSON_NOTIFICATION][JSON_PAYLOAD];
    QVector<const char*> jsonPath({JSON_NOTIFICATION, JSON_PAYLOAD});  // successfuly checked JSON path

    // check "name"
    if (checkKey(payload, JSON_NAME, KeyType::String, jsonPath) == false) {
        return false;
    }

    constexpr quint64 EMBEDDED = static_cast<quint64>(CONTROLLER_TYPE_EMBEDDED);
    constexpr quint64 ASSISTED = static_cast<quint64>(CONTROLLER_TYPE_ASSISTED);
    quint64 controller;
    {  // check "controller_type"
        if (checkKey(payload, JSON_CONTROLLER_TYPE, KeyType::Unsigned, jsonPath) == false) {
            return false;
        }
        controller = payload[JSON_CONTROLLER_TYPE].GetUint64();
        if (controller == 0) {
            emit validationStatus(Status::Warning, JSON_CONTROLLER_TYPE + QStringLiteral(" not set, continuing as EMBEDDED."));
            controller = EMBEDDED;
        }
        if ((controller != EMBEDDED) && (controller != ASSISTED)) {
            emit validationStatus(Status::Error, unsupportedValue(joinKeys(jsonPath, JSON_CONTROLLER_TYPE), QString::number(controller)));
            return false;
        }
        emit validationStatus(Status::Info, (controller == EMBEDDED) ? QStringLiteral("Embedded board.") : QStringLiteral("Assisted controller."));
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
                    return false;
                }
            }
        }
        // keys mandatory for assisted
        if (controller == ASSISTED) {
            if (keysBothCount == 0) {  // only dongle connected
                emit validationStatus(Status::Info, QStringLiteral("Assisted board not connected."));
            }
            for (size_t i = 0; i < keysAssist.size(); ++i) {
                if (checkKey(payload, keysAssist[i].key, keysAssist[i].type, jsonPath) == false) {
                    return false;
                }
            }
        }
        // check if there are some assisted keys for embedded platform
        if (controller == EMBEDDED) {
            for (size_t i = 0; i < keysAssist.size(); ++i) {
                if (keysAssist[i].present) {
                    emit validationStatus(Status::Error, QStringLiteral("Unexpected key '") + joinKeys(jsonPath, keysAssist[i].key) + QStringLiteral("'."));
                    return false;
                }
            }
        }
    }

    return true;
}

}  // namespace
