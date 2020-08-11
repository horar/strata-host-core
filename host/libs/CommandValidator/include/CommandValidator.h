#ifndef COMMANDVALIDATOR_H
#define COMMANDVALIDATOR_H

#include <string>
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
        reqPlatIdRes,
        setPlatIdRes,
        ack,
        notification,
        getFirmwareInfoRes,
        flashFirmwareRes,
        backupFirmwareRes,
        flashBootloaderRes,
        updateFirmwareRes,
        startAppRes,
        strataCmd,
        cmd
    };

private:
    // Basic commands
    static const rapidjson::SchemaDocument requestPlatformIdResSchema;
    static const rapidjson::SchemaDocument setPlatformIdResSchema;
    static const rapidjson::SchemaDocument ackSchema;
    static const rapidjson::SchemaDocument notificationSchema;
    static const rapidjson::SchemaDocument getFirmwareInfoResSchema;
    static const rapidjson::SchemaDocument flashFirmwareResSchema;
    static const rapidjson::SchemaDocument backupFirmwareResSchema;
    static const rapidjson::SchemaDocument flashBootloaderResSchema;
    static const rapidjson::SchemaDocument updateFirmwareResSchema;
    static const rapidjson::SchemaDocument startAppResSchema;
    static const rapidjson::SchemaDocument strataCommandSchema;
    static const rapidjson::SchemaDocument cmdSchema;

    static const std::map<const JsonType, const rapidjson::SchemaDocument&> schemas;

    static rapidjson::SchemaDocument parseSchema(const std::string &schema, bool *isOK = nullptr);

public:
    /**
     * Validate the command.
     * @post If the command is valid it will be parsed in doc.
     * @param command[in] The string containing JSON command.
     * @param type[in] Type of JSON command (value from enum CommandValidator::JsonType).
     * @param doc[out] The rapidjson::Document where command will be parsed.
     * @return True if the the command is valid, False otherwise.
     */
    static bool validate(const std::string &command, const JsonType type, rapidjson::Document &doc);

    /**
     * Validate the command.
     * @post If the command is valid it will be parsed in doc.
     * @param command[in] The string containing JSON command.
     * @param schema[in] The string containing JSON schema.
     * @param doc[out] The rapidjson::Document where command will be parsed.
     * @return True if the the command is valid, False otherwise.
     */
    static bool validate(const std::string &command, const std::string& schema, rapidjson::Document &doc);

    /**
     * Validate the command.
     * @param type[in] Type of JSON command (value from enum CommandValidator::JsonType).
     * @param doc[in] The rapidjson::Document contatining JSON command.
     * @return True if the the command is valid, False otherwise.
     */
    static bool validate(const JsonType type, const rapidjson::Document &doc);

    /**
     * Check if the command is valid JSON.
     * @param command[in] The string containing JSON command.
     * @return true if the the command is valid, false otherwise.
     */
    static bool isValidJson(const std::string &command);

    /**
     * Parse the command to JSON document.
     * @post If the command is valid JSON it will be parsed in doc.
     * @param command[in] The string containing JSON command.
     * @param doc[out] The rapidjson::Document where command will be parsed.
     * @return true if the the command is valid JSON, false otherwise.
     */
    static bool parseJson(const std::string &command, rapidjson::Document &doc);


private:
    /**
     * Validate json document against schema.
     *
     * @return true if the the command is valid, false otherwise.
     */
    static bool validateDocWithSchema(const rapidjson::SchemaDocument &schema, const rapidjson::Document &doc);


};

#endif // COMMANDVALIDATOR_H
