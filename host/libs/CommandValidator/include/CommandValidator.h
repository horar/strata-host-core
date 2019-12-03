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

public:
    CommandValidator(/* args */);
    ~CommandValidator();

    static rapidjson::SchemaDocument parseSchema(const std::string &schema);
    static bool isValidSetPlatformId(const std::string &command);
    static bool isValidRequestPlatorfmIdResponse(const std::string &command);
    static bool isValidAck(const std::string &command);
    static bool isValidNotification(const std::string &command);
    static bool isValidGetFWInfo(const std::string &command);
    static bool isValidFlashFW(const std::string &command);
    static bool isValidUpdateFW(const std::string &command);
    static bool validateCommandWithSchema(const std::string &command, const std::string &schema);
    static bool validateCommandWithSchema(const std::string &command, const rapidjson::SchemaDocument &schema);
    static bool isValidJson(const std::string &command);
};
