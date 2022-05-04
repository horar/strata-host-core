/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef COMMANDVALIDATOR_H
#define COMMANDVALIDATOR_H

#include <QByteArray>
#include <QString>

#include <map>

#include <rapidjson/schema.h>
#include <rapidjson/document.h>

namespace strata {

/**
 * Static class to validate commands.
 */
class CommandValidator
{
public:
    enum class JsonType {
        cmd,
        ack,
        notification,
        reqPlatformIdNotif,
        setPlatformIdNotif,
        setAssistedPlatformIdNotif,
        getFirmwareInfoNotif,
        startBootloaderNotif,
        startApplicationNotif,
        startFlashFirmwareNotif,
        flashFirmwareNotif,
        startBackupFirmwareNotif,
        backupFirmwareNotif,
        startFlashBootloaderNotif,
        flashBootloaderNotif,
        strataCommand
    };

private:
    // Basic commands
    static const rapidjson::SchemaDocument cmdSchema_;
    static const rapidjson::SchemaDocument ackSchema_;
    static const rapidjson::SchemaDocument notificationSchema_;
    static const rapidjson::SchemaDocument notifPayloadStatusSchema_;
    static const rapidjson::SchemaDocument reqPlatformId_nps_;  // nps = notification payload schema
    static const rapidjson::SchemaDocument getFirmwareInfo_nps_;
    static const rapidjson::SchemaDocument startBackupFirmware_nps_;
    static const rapidjson::SchemaDocument backupFirmware_nps_;
    static const rapidjson::SchemaDocument strataCommandSchema_;
    static const rapidjson::SchemaDocument setPlatformId_nps_;
    static const rapidjson::SchemaDocument setAssistedPlatformId_nps_;

    static const std::map<const JsonType, const rapidjson::SchemaDocument&> schemas_;
    static const std::map<const JsonType, const char*> notifications_;

    static QString lastValidationError_;

public:
    /**
     * Parse JSON schema into rapidjson::SchemaDocument.
     * @param schema[in] JSON schema
     * @param isOk[out] true if schema was parsed successfully, false otherwise
     * @return rapidjson::SchemaDocument
     */
    static rapidjson::SchemaDocument parseSchema(const QByteArray &schema, bool *isOk = nullptr);

    /**
     * Validate json document against schema.
     * @param schema[in] The rapidjson::SchemaDocument containing schema.
     * @param json[in] The rapidjson::Value contatining JSON (accepts also rapidjson::Document).
     * @param quiet[in] If set to true, nothing is written to log (and 'last validation error' contains generic error).
     * @return true if the the command is valid, false otherwise.
     */
    static bool validateJsonWithSchema(const rapidjson::SchemaDocument &schema, const rapidjson::Value &json, bool quiet = false);

    /**
     * Validate the command.
     * @post If the command is valid it will be parsed in doc.
     * @param command[in] The string containing JSON command.
     * @param type[in] Type of JSON command (value from enum CommandValidator::JsonType).
     * @param doc[out] The rapidjson::Document where command will be parsed.
     * @return True if the the command is valid, False otherwise.
     */
    static bool validate(const QByteArray &command, const JsonType type, rapidjson::Document &doc);

    /**
     * Validate the command.
     * @post If the command is valid it will be parsed in doc.
     * @param command[in] The string containing JSON command.
     * @param schema[in] The string containing JSON schema.
     * @param doc[out] The rapidjson::Document where command will be parsed.
     * @return True if the the command is valid, False otherwise.
     */
    static bool validate(const QByteArray &command, const QByteArray& schema, rapidjson::Document &doc);

    /**
     * Validate the command.
     * @param type[in] Type of JSON command (value from enum CommandValidator::JsonType).
     * @param doc[in] The rapidjson::Document contatining JSON command.
     * @return True if the the command is valid, False otherwise.
     */
    static bool validate(const JsonType type, const rapidjson::Document &doc);

    /**
     * Validate the notification.
     * @param type[in] Type of JSON notification (value from enum CommandValidator::JsonType).
     * @param doc[in] The rapidjson::Document contatining JSON command.
     * @return True if the the notification is valid, False otherwise.
     */
    static bool validateNotification(const JsonType type, const rapidjson::Document &doc);

    /**
     * Check if the command is valid JSON.
     * @param command[in] The string containing JSON command.
     * @return true if the the command is valid, false otherwise.
     */
    static bool isValidJson(const QByteArray &command);

    /**
     * Parse the command to JSON document.
     * @post If the command is valid JSON it will be parsed in doc.
     * @param command[in] The string containing JSON command.
     * @param doc[out] The rapidjson::Document where command will be parsed.
     * @param quiet[in] If set to true, nothing is written to log.
     * @return true if the the command is valid JSON, false otherwise.
     */
    static bool parseJsonCommand(const QByteArray &command, rapidjson::Document &doc, bool quiet = false);

    /**
     * Get status message from notification.
     * @param doc[in] The rapidjson::Document contatining JSON notification.
     * @return status string (/notification/payload/status) or empty array
     */
    static QByteArray notificationStatus(const rapidjson::Document &doc);

    /**
     * Get last error from validation against schema. This function is not reentrant and thered safe!
     * @return error from last validation (empty if none error occured)
     */
    static QString lastValidationError();
};

}  // namespace

#endif // COMMANDVALIDATOR_H
