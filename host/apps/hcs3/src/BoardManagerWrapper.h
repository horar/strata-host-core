#ifndef HCS_BOARDMANAGERWRAPPER_H__
#define HCS_BOARDMANAGERWRAPPER_H__

#include <QObject>
#include <QHash>

#include <BoardManager.h>


class PlatformBoard;

/*
This BoardManagerWrapper class is replacement for original classes BoardsController and PlatformBoard.

Instead of two original classes is now used BoardManager which is wrapped due to compatibility
with rest of current HCS implementation.

Functions in this BoardManagerWrapper class are very similar as original ones from BoardsController class.
BoardsController managed PlatformBoard objects (one PlatformBoard object for one device).

PlatformBoard class held information about board and also shared pointer to PlatformConnection object
which managed communication with serial device. Properties which was held by PlatformBoard class are
now in Board struct.

All (serial port) devices are now managed by BoardManager where devices are identified by device ID.
To be compatible with rest rest of current HCS implementation we need to have some information about connected
devices. This information are stored in boards_ map.
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
     */
    void initialize();

    /**
     * Sends message to board specified by device Id
     * @param deviceId
     * @param message
     */
    void sendMessage(const int deviceId, const std::string& message);

    /**
     * Creates JSON with list of platforms
     * @param[out] result
     */
    void createPlatformsList(std::string& result);

    /**
     * Gets client ID of board specified by device ID
     * @param deviceId
     * @return client ID
     */
    std::string getClientId(const int deviceId) const;

    /**
     * Gets class ID of board specified by device ID
     * @param deviceId
     * @return class ID
     */
    std::string getClassId(const int deviceId) const;

    /**
     * Gets platform ID of board specified by device ID
     * @param deviceId
     * @return platform ID
     */
    std::string getPlatformId(const int deviceId) const;

    /**
     * Gets device ID for board with specified client ID
     * @param[in] clientId
     * @param[out] deviceId
     * @return true if operation was successful, otherwise false (invalid clientId)
     */
    bool getDeviceIdByClientId(const std::string& clientId, int& deviceId) const;

    /**
     * Gets device ID for board with specified class ID
     * @param[in] classId
     * @param[out] deviceId
     * @return true if operation was successful, otherwise false (invalid deviceId)
     */
    bool getFirstDeviceIdByClassId(const std::string& classId, int& deviceId) const;

    /**
     * Sets client ID for board specified by device ID
     * @param clientId
     * @param deviceId
     * @return true if operation was successful, otherwise false
     */
    bool setClientId(const std::string& clientId, const int deviceId);

    /**
     * Clears client ID for board specified by device ID
     * @param connectionId
     * @return true if operation was successful, otherwise false (invalid deviceId)
     */
    bool clearClientId(const int deviceId);

signals:
    void boardConnected(QString classId, QString platformId);
    void boardDisconnected(QString classId, QString platformId);
    void boardMessage(QString platformId, QString message);

private slots:  // slots for signals from BoardManager

    void newConnection(int deviceId, bool recognized);
    void closeConnection(int deviceId);
    void messageFromBoard(QString message);

private:
    // Auxiliary function for writing log messages.
    inline QString logDeviceId(const int deviceId) const;

    struct Board {
        Board(const strata::SerialDevicePtr& devPtr);
        strata::SerialDevicePtr device;
        std::string clientId;
    };

    strata::BoardManager boardManager_;

    // map: deviceID <-> Board
    QHash<int, Board> boards_;
    // access to boards_ should be protected by mutex in case of multithread usage
};

#endif // HCS_BOARDMANAGERWRAPPER_H__
