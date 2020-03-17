#ifndef HCS_BOARDMANAGERWRAPPER_H__
#define HCS_BOARDMANAGERWRAPPER_H__

#include <QObject>

#include <map>

#include <BoardManager.h>


class PlatformBoard;
class HCS_Dispatcher;

/*
This BoardManagerWrapper class is replacement for original classes BoardsController and PlatformBoard.

Instead of two original classes is now used BoardManager which is wrapped due to compatibility
with rest of current HCS implementation.

Functions in this BoardManagerWrapper class are very similar as original ones from BoardsController class.
BoardsController managed PlatformBoard objects (one PlatformBoard object for one device).

PlatformBoard class held information about board and also shared pointer to PlatformConnection object
which managed communication with serial device. Properties which was held by PlatformBoard class are
now in BoardInfo struct.

All (serial port) devices are now managed by BoardManager where devices are identified by connection ID.
To be compatible with rest rest of current HCS implementation we need to have some information about connected
devices. This information are stored in boardInfo_ map.
*/
class BoardManagerWrapper final : public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(BoardManagerWrapper)

public:
    /**
     * BoardManagerWrapper constructor
     */
    BoardManagerWrapper();

    /**
     * Initializes the board manager
     * @param dispatcher
     */
    void initialize(HCS_Dispatcher* dispatcher);

    /**
     * Sends message to specified connection Id
     * @param connectionId
     * @param message
     */
    void sendMessage(const int connectionId, const std::string& message);

    /**
     * Creates JSON with list of platforms
     * @param[out] result
     */
    void createPlatformsList(std::string& result);

    /**
     * Gets client ID of board specified by connection ID
     * @param connectionId
     * @return client ID
     */
    std::string getClientId(const int connectionId) const;

    /**
     * Gets class ID of board specified by connection ID
     * @param connectionId
     * @return class ID
     */
    std::string getClassId(const int connectionId) const;

    /**
     * Gets platform ID of board specified by connection ID
     * @param connectionId
     * @return platform ID
     */
    std::string getPlatformId(const int connectionId) const;

    /**
     * Gets connection ID for board with specified client ID
     * @param[in] clientId
     * @param[out] connectionId
     * @return true if operation was successful, otherwise false (invalid connectionId)
     */
    bool getConnectionIdByClientId(const std::string& clientId, int& connectionId) const;

    /**
     * Gets connection ID for board with specified class ID
     * @param[in] classId
     * @param[out] connectionId
     * @return true if operation was successful, otherwise false (invalid connectionId)
     */
    bool getFirstConnectionIdByClassId(const std::string& classId, int& connectionId) const;

    /**
     * Sets client ID for board specified by connection ID
     * @param clientId
     * @param connectionId
     * @return true if operation was successful, otherwise false
     */
    bool setClientId(const std::string& clientId, const int connectionId);

    /**
     * Clears client ID for board specified by connection ID
     * @param connectionId
     * @return true if operation was successful, otherwise false (invalid connectionId)
     */
    bool clearClientId(const int connectionId);

private slots:  // slots for signals from BoardManager

    void newConnection(int connectionId, bool recognized);

    void closeConnection(int connectionId);

    void messageFromConnection(int connectionId, QString message);

private:
    // Auxiliary function for writing log messages.
    inline QString logConnectionId(const int connectionId) const;

    struct BoardInfo {
        BoardInfo(QString clssId, QString pltfId, QString vName);
        std::string classId;
        std::string platformId;
        std::string verboseName;
        std::string clientId;
    };

    strata::BoardManager boardManager_;

    HCS_Dispatcher* dispatcher_{nullptr};

    // map: board (connection ID) <-> BoardInfo
    std::map<int, BoardInfo> boardInfo_;
    // access to boardInfo_ should be protected by mutex in case of multithread usage
};

#endif // HCS_BOARDMANAGERWRAPPER_H__
