#ifndef HCS_BOARDCONTROLLER_H__
#define HCS_BOARDCONTROLLER_H__

#include <QObject>
#include <QString>
#include <QHash>

#include <BoardManager.h>

/*
This BoardController class is replacement for original classes BoardsController and PlatformBoard.

Instead of two original classes is now used BoardManager.

Functions in this BoardController class are very similar as original ones from BoardsController class.
BoardsController managed PlatformBoard objects (one PlatformBoard object for one device).

PlatformBoard class held information about board and also shared pointer to PlatformConnection object
which managed communication with serial device. Properties which was held by PlatformBoard class are
now in Board struct.

All (serial port) devices are now managed by BoardManager where devices are identified by device ID.
To be compatible with rest rest of current HCS implementation we need to have some information about connected
devices. This information are stored in boards_ map.
*/
class BoardController final : public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(BoardController)

public:
    /**
     * BoardController constructor
     */
    BoardController();

    /**
     * Initializes the board controller
     */
    void initialize();

    /**
     * Sends message to board specified by device Id
     * @param deviceId
     * @param message
     * @return true if massage can be sent
     */
    bool sendMessage(const int deviceId, const QByteArray& message);

    /**
     * Gets device specified by device ID
     * @param deviceId
     * @return device or nullptr if such device with device ID is not available
     */
    strata::device::DevicePtr getDevice(const int deviceId) const;

    /**
     * Creates JSON with list of platforms
     * @return list of platforms in JSON format
     */
    QString createPlatformsList();

    /**
     * Gets class ID of board specified by device ID
     * @param deviceId
     * @return class ID
     */
    QString getClassId(const int deviceId) const;

    /**
     * Gets platform ID of board specified by device ID
     * @param deviceId
     * @return platform ID
     */
    QString getPlatformId(const int deviceId) const;

    /**
     * Clears client ID for board specified by device ID
     * @param connectionId
     * @return true if operation was successful, otherwise false (invalid deviceId)
     */
    bool clearClientId(const int deviceId);

    /**
     * Clears specified client ID from all boards
     * @param clientId
     * @return true if operation was successful, otherwise false (clientId not attached to any boards)
     */
    bool clearClientIdFromAllDevices(const QByteArray& clientId);

signals:
    void boardConnected(int deviceId, QString classId, QString platformId);
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
        Board(const strata::device::DevicePtr& devPtr);
        strata::device::DevicePtr device;
        QByteArray clientId;
    };

    strata::BoardManager boardManager_;

    // map: deviceID <-> Board
    QHash<int, Board> boards_;
    // access to boards_ should be protected by mutex in case of multithread usage
};

#endif // HCS_BOARDCONTROLLER_H__
