#ifndef SCI_PLATFORMBOARD_H
#define SCI_PLATFORMBOARD_H

#include <string>

namespace spyglass {
    class PlatformConnection;
}

enum class ProcessResult {
    eParseError = -1,
    eIgnored = 0,      //forward message to further processing
    eProcessed,        //processed
};

class PlatformBoard
{
public:
    explicit PlatformBoard(spyglass::PlatformConnection* connection);
    virtual ~PlatformBoard();

    void sendInitialMsg();

    ProcessResult handleMessage(const std::string& msg);

    std::string getPlatformId() const { return platformId_; }
    std::string getVerboseName() const { return verboseName_; }

    bool isPlatformConnected() const { return (state_ == State::eConnected); }

private:
    int parseInitialMsg(const std::string& msg, bool& wasNotification);

private:
    enum class State {
        eInit = 0,
        eSendInitialMsg,
        eConnected,
    };

    std::string conn_id_;
    std::string platformId_;
    std::string verboseName_;

    spyglass::PlatformConnection* connection_ = nullptr;

    enum State state_ = State::eInit;
};


#endif //SCI_PLATFORMBOARD_H
