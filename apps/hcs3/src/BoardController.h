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
    bool sendMessage(const QByteArray& deviceId, const QByteArray& message);

    /**
     * Gets device specified by device ID
     * @param deviceId
     * @return device or nullptr if such device with device ID is not available
     */
    strata::device::DevicePtr getDevice(const QByteArray& deviceId) const;

    /**
     * Creates JSON with list of platforms
     * @return list of platforms in QJsonArray
     */
    QJsonArray createPlatformsList();

signals:
    void boardConnected(QByteArray deviceId);
    void boardDisconnected(QByteArray deviceId);
    void boardMessage(QString platformId, QString message);

private slots:  // slots for signals from BoardManager
    void newConnection(const QByteArray& deviceId, bool recognized);
    void closeConnection(const QByteArray& deviceId);
    void messageFromBoard(QString message);

private:
    struct Board {
        Board(const strata::device::DevicePtr& devPtr);
        strata::device::DevicePtr device;
    };

    strata::BoardManager boardManager_;

    // map: deviceID <-> Board
    QHash<QByteArray, Board> boards_;
    // access to boards_ should be protected by mutex in case of multithread usage
};

#endif // HCS_BOARDCONTROLLER_H__
