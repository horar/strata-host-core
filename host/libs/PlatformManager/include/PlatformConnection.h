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
    class EvCommEvent;
#endif

    class PlatformConnection final {
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
         * @return negative number means error, positive numbers means number of bytes read
         *         -10 means port is not open
         */
        int waitForMessages(unsigned int timeout);

        /**
         * @return returns name of the connection (after successful open)
         */
        std::string getName() const;

        /**
         * @return Checks if there is a message available
         */
        bool isReadable();

        /**
         * Creates and returns event for registration in Event dispatcher
         */
        EvEventBase* createEvent();

        /**
         * @return returns event.
         */
        EvEventBase* getEvent();

        /**
         * Deactivates and releases the event
         * @return returns true when successeded otherwise false
         */
        bool releaseEvent();

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

        /**
         * Updates activation/deactivation of the event, especially read/write state
         * @param read
         * @param write
         * @return returns true when successful otherwise false
         */
        bool updateEvent(bool read, bool write);

        /**
         * return if write buffer is empty.
         * NOTE: this method is not thread safe
         */
        bool isWriteBufferEmpty() const;

        /**
         * handles callbacks from events
         * @param flags - flags for indicating read/write event
         */
        void onDescriptorEvent(EvEventBase*, int flags);

    private:
        PlatformManager *parent_;
        std::unique_ptr<serial_port> port_;
        std::string portName_;

#if defined(__linux__) || defined(__APPLE__)
        std::unique_ptr<EvEvent> event_;
#elif defined(_WIN32)
        std::unique_ptr<EvCommEvent> event_;
#endif
        std::recursive_mutex event_lock_;  //this lock is used when read/write event is notified or when event is attached/detached

        std::string readBuffer_;
        std::string writeBuffer_;

        unsigned int readOffset_ = 0;
        unsigned int writeOffset_ = 0;

        std::mutex readLock_;
        std::mutex writeLock_;

    };

    typedef std::shared_ptr<PlatformConnection> PlatformConnectionShPtr;

    /**
     * Helper class for pause/resume connection listening
     */
    class PauseConnectionListenerGuard final
    {
    public:
        PauseConnectionListenerGuard(PlatformConnectionShPtr connection) {
            if (connection) {
                connection_ = connection;
                connection_->stopListeningOnEvents(true);
            }
        }

        ~PauseConnectionListenerGuard() {
            if (connection_) {
                connection_->stopListeningOnEvents(false);
            }
        }

        void attach(PlatformConnectionShPtr connection) {
            if (connection_) {
                connection_->stopListeningOnEvents(false);
            }

            connection_ = connection;
            if (connection_) {
                connection_->stopListeningOnEvents(true);
            }
        }

    private:
        spyglass::PlatformConnectionShPtr connection_;
    };


} //end of namespace

#endif //PROJECT_CONNECTION_H
