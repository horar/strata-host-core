#ifndef PROJECT_PLATFORMMANAGER_H
#define PROJECT_PLATFORMMANAGER_H

#include <vector>
#include <map>
#include <string>
#include <functional>

#include <EvEventsMgr.h>

namespace spyglass {

    typedef size_t serialPortHash;

    class PlatformConnection;

    /**
     * Pure virtual interface for connection handling
     */
    class PlatformConnHandler {
    public:
        virtual void onNewConnection(PlatformConnection *connection) = 0;

        virtual void onCloseConnection(PlatformConnection *connection) = 0;

        virtual void onNotifyReadConnection(PlatformConnection *connection) = 0;
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
        void StartLoop();

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
        PlatformConnection* getConnection(const std::string& connection_id);

        /**
         * stops listens on requested connection
         */
        void stopListenOnConnection(PlatformConnection* connection);

        /**
         * resume listens on requested connection
         */
        void resumeListenOnConnection(PlatformConnection* connection);

    protected:
        void onAddedPort(serialPortHash hash);

        void onRemovedPort(serialPortHash hash);

        void notifyConnectionReadable(PlatformConnection *conn);

        void removeConnection(PlatformConnection *conn);

        EvEventsMgr* getEvEventsMgr() { return &eventsMgr_; }

    private:
        void onUpdatePortList(EvEvent *, int);

    private:
        void computeListDiff(const std::vector<serialPortHash> &list,
                             std::vector<serialPortHash> &added_ports,
                             std::vector<serialPortHash> &removed_ports);

        std::string hashToPortName(serialPortHash hash);

    private:
        std::vector<serialPortHash> portsList_;
        std::map<serialPortHash, std::string> hashToName_;

        std::mutex connectionMap_mutex_;
        std::map<serialPortHash, PlatformConnection *> openedPorts_;

        PlatformConnHandler *plat_handler_ = nullptr;

        EvEventsMgr eventsMgr_;
        std::unique_ptr<EvEvent> ports_update_;

        friend class PlatformConnection;
    };

} //end of namespace

#endif //PROJECT_PLATFORMMANAGER_H
