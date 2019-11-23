#include <string>
#include <rapidjson/schema.h>
#include <rapidjson/document.h>

class CommandValidator
{
private:
    // Basic commands
    static const std::string requestPlatformIdResSchema;
    static const std::string setPlatformIdResSchema;
    static const std::string ackSchema;
    static const std::string notificationSchema;
    static const std::string getFWInfoResSchema;
    static const std::string flashFWResSchema;
    static const std::string updateFWResSchema;

public:
    CommandValidator(/* args */);   // delete?
    ~CommandValidator();            // delete?

    static bool isValidSetPlatformId(const std::string &command);
    static bool isValidRequestPlatorfmIdResponse(const std::string &command);
    static bool isValidAck(const std::string &command);
    static bool isValidNotification(const std::string &command);
    static bool isValidGetFWInfo(const std::string &command);
    static bool isValidFlashFW(const std::string &command);
    static bool isValidUpdateFW(const std::string &command);
    static bool validateCommandWithSchema(const std::string &command, const std::string &schema);

};
