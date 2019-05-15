#ifndef SCI_PLATFORMBOARD_H
#define SCI_PLATFORMBOARD_H

#include <string>
#include <PlatformManager.h>

class PlatformBoard
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

    std::string getPlatformId() const;
    std::string getVerboseName() const;
    std::string getBootloaderVersion() const;
    std::string getApplicationVersion() const;

    bool isPlatformConnected() const { return (state_ == State::eConnected); }

private:
    ProcessResult parseInitialMsg(const std::string& msg, bool& wasNotification);

private:
    enum class State {
        eInit = 0,
        eWaitingForFirmwareInfo,
        eWaitingForPlatformInfo,
        eConnected,
    };

    std::string platformId_;
    std::string verboseName_;
    std::string bootloaderVersion_;
    std::string applicationVersion_;

    spyglass::PlatformConnectionShPtr connection_;

    enum State state_;
};


#endif //SCI_PLATFORMBOARD_H
