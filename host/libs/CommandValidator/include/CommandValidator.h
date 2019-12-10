#include <string>
#include <rapidjson/schema.h>
#include <rapidjson/document.h>

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

public:
    CommandValidator(/* args */);
    ~CommandValidator();

    static rapidjson::SchemaDocument parseSchema(const std::string &schema);
    static bool isValidSetPlatformId(const std::string &command, rapidjson::Document &doc);
    static bool isValidRequestPlatorfmIdResponse(const std::string &command, rapidjson::Document &doc);
    static bool isValidAck(const std::string &command, rapidjson::Document &doc);
    static bool isValidNotification(const std::string &command, rapidjson::Document &doc);
    static bool isValidGetFWInfo(const std::string &command, rapidjson::Document &doc);
    static bool isValidFlashFW(const std::string &command, rapidjson::Document &doc);
    static bool isValidUpdateFW(const std::string &command, rapidjson::Document &doc);
    static bool isValidStrataCommand(const std::string &command, rapidjson::Document &doc);
    static bool isValidCmdCommand(const std::string &command, rapidjson::Document &doc);
    static bool validateCommandWithSchema(const std::string &command, const std::string &schema, rapidjson::Document &doc);
    static bool validateCommandWithSchema(const std::string &command, const rapidjson::SchemaDocument &schema, rapidjson::Document &doc);
    static bool isValidJson(const std::string &command, rapidjson::Document &doc);
};
