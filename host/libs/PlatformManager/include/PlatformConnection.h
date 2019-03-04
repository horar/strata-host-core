#ifndef PROJECT_CONNECTION_H
#define PROJECT_CONNECTION_H

#include <string>
#include <mutex>
#include <memory>

class serial_port;

namespace spyglass {

    class EvEvent;
    class EvEventsMgr;
    class PlatformManager;

    class PlatformConnection {
    public:
        PlatformConnection(PlatformManager *parent);

        ~PlatformConnection();

        /**
         * Opens connection on serial port specified by name
         * @param port_name - name of the serial port (device)
         * @return returns true when success otherwise false
         */
        bool open(const std::string &portName);

        /**
         * Closes opened connection
         */
        void close();

        /**
         * Returns single platform message when available
         * @param result platform message
         * @return returns true when message present, otherwise false
         */
        bool getMessage(std::string &result);

        /**
         * Adds message to queue for sending
         * @param message message to send
         */
        void addMessage(const std::string &message);

        /**
         * Sends message over connection
         * @param message message to send
         */
        void sendMessage(const std::string &message);

        /**
         * Waits for messages for specified amount of time
         * @param timeout amount of time to wait
         */
        int waitForMessages(int timeout);

        /**
         * @return returns name of the connection
         */
        std::string getName() const;

        /**
         * @return Checks if there is a message available
         */
        bool isReadable();

        /**
         * Attaches EvEventsMgr to the connection to handle read/write notifications
         *  it is method for PlatformManager
         * @param ev_manager manager to attach
         */
        void attachEventMgr(EvEventsMgr *ev_manager);

        /**
         * Detaches EvEventsMgr from connection
         */
        void detachEventMgr();

    private:
        int handleRead(int timeout);

        int handleWrite(int timeout);

        void onDescriptorEvent(EvEvent *, int flags);

        bool updateEvent(bool read, bool write);

        bool isWriteBufferEmpty() const;


    private:
        PlatformManager *parent_;
        std::unique_ptr<serial_port> port_;

        EvEventsMgr *event_mgr_ = nullptr;
        std::unique_ptr<EvEvent> event_;

        std::string readBuffer_;
        std::string writeBuffer_;

        int readOffset_ = 0;
        int writeOffset_ = 0;

        std::mutex readLock_;
        std::mutex writeLock_;

    };

} //end of namespace

#endif //PROJECT_CONNECTION_H
