#ifndef PROJECT_PLATFORMMANAGER_H
#define PROJECT_PLATFORMMANAGER_H

#include <vector>
#include <map>
#include <string>
#include <functional>
#include <mutex>
#include <memory>

#if defined(__linux__) || defined(__APPLE__)
#include <EvEventsMgr.h>
#elif defined(_WIN32)
#include <win32/EvCommWaitManager.h>
#include <win32/EvTimerEvent.h>
#endif

namespace spyglass {

    typedef size_t serialPortHash;

    class PlatformConnection;
    class EvEventBase;

    typedef std::shared_ptr<PlatformConnection> PlatformConnectionShPtr;

    /**
     * Pure virtual interface for connection handling
     */
    class PlatformConnHandler {
    public:
        virtual void onNewConnection(PlatformConnectionShPtr connection) = 0;

        virtual void onCloseConnection(PlatformConnectionShPtr connection) = 0;

        virtual void onNotifyReadConnection(PlatformConnectionShPtr connection) = 0;
    };

    class PlatformManager {
    public:
        PlatformManager();

        ~PlatformManager();

        /**
         * Initializes the platform manager
         * @return returns true when successful otherwise false
         */
        bool Init();

        /**
         * Starts event loop in different thread that handles connections
         */
        bool StartLoop();

        /**
         * Stops event loop and destroys thread
         */
        void Stop();

        /**
         * Attaches handler for new/removed/read ready connections
         * @param handler handler to attach
         */
        void setPlatformHandler(PlatformConnHandler *handler);

        /**
         * Returns connection object according 'connection_id'
         * @param connection_id search for
         * @return returns connection object or null when not found
         */
        PlatformConnectionShPtr getConnection(const std::string& connection_id);

        /**
         * Closes and removes connection from PlatformManager
         * @param connection_id to remove
         */
        bool removeConnection(const std::string& connection_id);

    protected:
        void onAddedPort(serialPortHash hash);

        void onRemovedPort(serialPortHash hash);

        void onRemoveClosedPort(serialPortHash hash);

        void notifyConnectionReadable(const std::string& connection_id);

        void onUpdatePortList(EvEventBase*, int);

        void unregisterConnection(const std::string& connection_id);

    private:


    private:
        void computeListDiff(const std::vector<serialPortHash> &list,
                             std::vector<serialPortHash> &added_ports,
                             std::vector<serialPortHash> &removed_ports);

        std::string hashToPortName(serialPortHash hash);

    private:
        std::vector<serialPortHash> portsList_;
        std::map<serialPortHash, std::string> hashToName_;

        std::mutex connectionMap_mutex_;
        std::map<serialPortHash, PlatformConnectionShPtr> openedPorts_;

        std::mutex closedPorts_mutex_;
        std::map<serialPortHash, PlatformConnectionShPtr> closedPorts_;

        PlatformConnHandler *plat_handler_ = nullptr;

#if defined(__linux__) || defined(__APPLE__)
        EvEventsMgr eventsMgr_;
        std::unique_ptr<EvEvent> ports_update_;

#elif defined(_WIN32)
        EvCommWaitManager eventsMgr_;

        EvCommWaitManager portsUpdateThread_;
        std::unique_ptr<EvTimerEvent> ports_update_;
#endif

        friend class PlatformConnection;
    };

} //end of namespace

#endif //PROJECT_PLATFORMMANAGER_H
