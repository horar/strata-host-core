#ifndef COMMANDVALIDATOR_H
#define COMMANDVALIDATOR_H

#include <string>
#include <rapidjson/schema.h>
#include <rapidjson/document.h>

/**
 * Static class to validate commands.
 */
class CommandValidator
{
private:
    // Basic commands
    static const rapidjson::SchemaDocument requestPlatformIdResSchema;
    static const rapidjson::SchemaDocument setPlatformIdResSchema;
    static const rapidjson::SchemaDocument ackSchema;
    static const rapidjson::SchemaDocument notificationSchema;
    static const rapidjson::SchemaDocument getFWInfoResSchema;
    static const rapidjson::SchemaDocument flashFWResSchema;
    static const rapidjson::SchemaDocument updateFWResSchema;
    static const rapidjson::SchemaDocument strataCommandSchema;
    static const rapidjson::SchemaDocument cmdSchema;

    static rapidjson::SchemaDocument parseSchema(const std::string &schema, bool *isOK = nullptr);

public:
    CommandValidator(/* args */);
    ~CommandValidator();

    /**
     * Validate the response to set_platform_id command.
     *
     * @post If the command is valid it will be parsed in doc.
     * @return true if the the command is valid, false otherwise.
     */
    static bool isValidSetPlatformId(const std::string &command, rapidjson::Document &doc);

    /**
     * Validate the response to request_platfom_id command.
     * @note This function can be used with both platform id v1 and v2
     *
     * @post If the command is valid it will be parsed in doc.
     * @return true if the the command is valid, false otherwise.
     */
    static bool isValidRequestPlatorfmIdResponse(const std::string &command, rapidjson::Document &doc);

    /**
     * Validate the response to request_platfom_id command.
     * @note This function can be used with both platform id v1 and v2
     *
     * @return true if the the command is valid, false otherwise.
     */
    static bool isValidRequestPlatorfmIdResponse(const rapidjson::Document &doc);

    /**
     * Validate ack response.
     *
     * @post If the command is valid it will be parsed in doc.
     * @return true if the the command is valid, false otherwise.
     */
    static bool isValidAck(const std::string &command, rapidjson::Document &doc);

    /**
     * Validate ack response.
     *
     * @return true if the the command is valid, false otherwise.
     */
    static bool isValidAck(const rapidjson::Document &doc);

    /**
     * Validate notification commands.
     *
     * @post If the command is valid it will be parsed in doc.
     * @return true if the the command is valid, false otherwise.
     */
    static bool isValidNotification(const std::string &command, rapidjson::Document &doc);

    /**
     * Validate notification commands.
     *
     * @return true if the the command is valid, false otherwise.
     */
    static bool isValidNotification(const rapidjson::Document &doc);

    /**
     * Validate the response to get_firmware_info command.
     *
     * @post If the command is valid it will be parsed in doc.
     * @return true if the the command is valid, false otherwise.
     */
    static bool isValidGetFWInfo(const std::string &command, rapidjson::Document &doc);

    /**
     * Validate the response to get_firmware_info command.
     *
     * @return true if the the command is valid, false otherwise.
     */
    static bool isValidGetFWInfo(const rapidjson::Document &doc);

    /**
     * Validate the response to flash_firmware command.
     *
     * @post If the command is valid it will be parsed in doc.
     * @return true if the the command is valid, false otherwise.
     */
    static bool isValidFlashFW(const std::string &command, rapidjson::Document &doc);

    /**
     * Validate the response to update_firmware command.
     *
     * @post If the command is valid it will be parsed in doc.
     * @return true if the the command is valid, false otherwise.
     */
    static bool isValidUpdateFW(const std::string &command, rapidjson::Document &doc);

    /**
     * Validate the command based on Strata messegaing archticture.
     * @note This validates notification, ack, and cmd.
     *
     * @post If the command is valid it will be parsed in doc.
     * @return true if the the command is valid, false otherwise.
     */
    static bool isValidStrataCommand(const std::string &command, rapidjson::Document &doc);

    /**
     * Validate "cmd" commands.
     *
     * @post If the command is valid it will be parsed in doc.
     * @return true if the the command is valid, false otherwise.
     */
    static bool isValidCmdCommand(const std::string &command, rapidjson::Document &doc);

    /**
     * Validate json string against schema.
     *
     * @post If the command is valid it will be parsed in doc.
     * @return true if the the command is valid, false otherwise.
     */
    static bool validateCommandWithSchema(const std::string &command, const std::string &schema, rapidjson::Document &doc);

    /**
     * Validate json string against schema.
     *
     * @post If the command is valid it will be parsed in doc.
     * @return true if the the command is valid, false otherwise.
     */
    static bool validateCommandWithSchema(const std::string &command, const rapidjson::SchemaDocument &schema, rapidjson::Document &doc);

    /**
     * Validate json document against schema.
     *
     * @return true if the the command is valid, false otherwise.
     */
    static bool validateDocWithSchema(const rapidjson::SchemaDocument &schema, const rapidjson::Document &doc);

    /**
     * Check if the command is valid JSON.
     *
     * @return true if the the command is valid, false otherwise.
     */
    static bool isValidJson(const std::string &command);

    /**
     * Parse the command to JSON document.
     *
     * @post If the command is valid JSON it will be parsed in doc.
     * @return true if the the command is valid JSON, false otherwise.
     */
    static bool parseJson(const std::string &command, rapidjson::Document &doc);
};

#endif // COMMANDVALIDATOR_H
