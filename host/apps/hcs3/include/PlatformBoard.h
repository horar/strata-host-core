#ifndef HOST_HCS_PLATFORMBOARD_H__
#define HOST_HCS_PLATFORMBOARD_H__

#include <string>
#include <PlatformManager.h>

class PlatformBoard final
{
public:
    enum class ProcessResult {
        eValidationError = -2,
        eParseError = -1,
        eIgnored = 0,      //forward message to further processing
        eProcessed,        //processed
    };

public:
    explicit PlatformBoard(spyglass::PlatformConnectionShPtr connection);
    ~PlatformBoard() = default;

    void sendInitialMsg();
    void sendPlatformInfoMsg();

    ProcessResult handleMessage(const std::string& msg);

    std::string getProperty(const std::string& key);

    bool isPlatformConnected() const { return (state_ == State::eConnected); }

    bool setClientId(const std::string& clientId);
    void resetClientId();
    std::string getClientId() const { return clientId_; }

private:
    ProcessResult parseInitialMsg(const std::string& msg, bool& wasNotification);

private:
    enum class State {
        eInit = 0,
        eWaitingForFirmwareInfo,
        eWaitingForPlatformInfo,
        eConnected,
    };

    std::map<std::string, std::string> properties_;

    spyglass::PlatformConnectionShPtr connection_;

    enum State state_;

    std::string clientId_;      //clientId attached to or empty

};

#endif //HOST_HCS_PLATFORMBOARD_H__
