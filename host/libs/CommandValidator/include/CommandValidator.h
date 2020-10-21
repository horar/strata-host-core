#ifndef COMMANDVALIDATOR_H
#define COMMANDVALIDATOR_H

#include <QByteArray>

#include <map>

#include <rapidjson/schema.h>
#include <rapidjson/document.h>

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

    static const std::map<const JsonType, const rapidjson::SchemaDocument&> schemas_;
    static const std::map<const JsonType, const char*> notifications_;

    static rapidjson::SchemaDocument parseSchema(const QByteArray &schema, bool *isOk = nullptr);

public:
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
     * @return true if the the command is valid JSON, false otherwise.
     */
    static bool parseJsonCommand(const QByteArray &command, rapidjson::Document &doc);


private:
    /**
     * Validate json document against schema.
     *
     * @return true if the the command is valid, false otherwise.
     */
    static bool validateJsonWithSchema(const rapidjson::SchemaDocument &schema, const rapidjson::Value &json);


};

#endif // COMMANDVALIDATOR_H
