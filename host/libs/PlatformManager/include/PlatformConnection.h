#ifndef PROJECT_CONNECTION_H
#define PROJECT_CONNECTION_H

#include <string>
#include <mutex>
#include <memory>

class serial_port;

namespace spyglass {

    class PlatformManager;
    class EvEventBase;

#if defined(__linux__) || defined(__APPLE__)
    class EvEvent;
    class EvEventsMgr;
#elif defined(_WIN32)
    class WinEventBase;
    class WinCommEvent;
    class WinCommFakeEvent;
#endif

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
         * @return returns true when message was send, otherwise false
         */
        bool sendMessage(const std::string &message);

        /**
         * Waits for messages for specified amount of time
         * @param timeout amount of time to wait
         */
        int waitForMessages(unsigned int timeout);

        /**
         * @return returns name of the connection
         */
        std::string getName() const;

        /**
         * @return Checks if there is a message available
         */
        bool isReadable();

#if defined(__linux__) || defined(__APPLE__)
        /**
         * Attaches EvEventsMgr to the connection to handle read/write notifications
         *  it is method for PlatformManager
         * @param ev_manager manager to attach
         * @return returns true when succeeded otherwise false
         */
        bool attachEventMgr(EvEventsMgr* ev_manager);

        /**
         * Returns events manager that is PlatformConnection attached too
         *  or nullptr when isn't attached.
         */
        EvEventsMgr* getEventMgr() const { return event_mgr_; }
#elif defined(_WIN32)

        WinEventBase* getEvent();
        WinEventBase* getWriteEvent();

#endif

        /**
         * Detaches EvEventsMgr from connection
         */
        void detachEventMgr();

        /**
         * Stops / Resumes listening on events from PlatformManager(EvEventMgr)
         * @param stop true stops listening, false resume
         * @return returns true when succeeded otherwise false
         */
        bool stopListeningOnEvents(bool stop);

    private:

        /**
         * Handles read from device
         * @param timeout to wait for read
         * @return number of bytes readed or negative when error
         */
        int handleRead(unsigned int timeout);

        /**
         * Handles write to device
         * @param timeout
         * @return number of bytes written or negative when error
         */
        int handleWrite(unsigned int timeout);

        bool updateEvent(bool read, bool write);

        bool isWriteBufferEmpty() const;

        void onDescriptorEvent(EvEventBase*, int flags);


    private:
        PlatformManager *parent_;
        std::unique_ptr<serial_port> port_;

#if defined(__linux__) || defined(__APPLE__)
        EvEventsMgr *event_mgr_ = nullptr;
        std::unique_ptr<EvEvent> event_;
#elif defined(_WIN32)

        std::unique_ptr<WinCommEvent> event_;
        std::unique_ptr<WinCommFakeEvent> write_event_;

#endif
        std::recursive_mutex event_lock_;  //this lock is used when read/write event is notified or when event is attached/detached

        std::string readBuffer_;
        std::string writeBuffer_;

        unsigned int readOffset_ = 0;
        unsigned int writeOffset_ = 0;

        std::mutex readLock_;
        std::mutex writeLock_;

    };


    /**
     * Helper class for pause/resume connection listening
     */
    class PauseConnectionListenerGuard
    {
    public:
        PauseConnectionListenerGuard(PlatformConnection* connection = nullptr) : connection_(connection) {
            if (connection_) {
                connection->stopListeningOnEvents(true);
            }
        }

        ~PauseConnectionListenerGuard() {
            if (connection_) {
                connection_->stopListeningOnEvents(false);
            }
        }

        void attach(PlatformConnection* connection) {
            if (connection_ != nullptr) {
                connection_->stopListeningOnEvents(false);
            }

            connection_ = connection;
            if (connection_) {
                connection->stopListeningOnEvents(true);
            }
        }

    private:
        spyglass::PlatformConnection* connection_;
    };


} //end of namespace

#endif //PROJECT_CONNECTION_H
