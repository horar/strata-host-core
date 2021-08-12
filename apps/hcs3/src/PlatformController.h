#pragma once

#include <QObject>
#include <QString>
#include <QHash>

#include <PlatformManager.h>

/*
This PlatformController class is replacement for original classes BoardsController and PlatformBoard.

Instead of two original classes is now used PlatformManager.

Functions in this PlatformController class are very similar as original ones from BoardsController class.
BoardsController managed PlatformBoard objects (one PlatformBoard object for one platform).

PlatformBoard class held information about board and also shared pointer to PlatformConnection object
which managed communication with serial device. Properties which was held by PlatformBoard class are
now in Platform.

All (serial port) devices are now managed by PlatformManager where devices are identified by device ID.
To be compatible with rest rest of current HCS implementation we need to have some information about connected
devices. This information are stored in platforms_ map.
*/
class PlatformController final : public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(PlatformController)

public:
    /**
     * PlatformController constructor
     */
    PlatformController();

    /**
     * Initializes the platform controller
     */
    void initialize();

    /**
     * Sends message to platform specified by device Id
     * @param deviceId
     * @param message
     */
    void sendMessage(const QByteArray& deviceId, const QByteArray& message);

    /**
     * Gets platform specified by device ID
     * @param deviceId
     * @return platform or nullptr if such platform with device ID is not available
     */
    strata::platform::PlatformPtr getPlatform(const QByteArray& deviceId) const;

    /**
     * Creates JSON with list of platforms
     * @return list of platforms in JSON format
     */
    QJsonObject createPlatformsList();

signals:
    void platformConnected(QByteArray deviceId);
    void platformDisconnected(QByteArray deviceId);
    void platformMessage(QString platformId, QJsonObject message);

private slots:  // slots for signals from PlatformManager
    void newConnection(const QByteArray& deviceId, bool recognized);
    void closeConnection(const QByteArray& deviceId);
    void messageFromPlatform(strata::platform::PlatformMessage message);
    void messageToPlatform(QByteArray rawMessage, unsigned msgNumber, QString errorString);

private:
    strata::PlatformManager platformManager_;

    // map: deviceID <-> Platform
    QHash<QByteArray, strata::platform::PlatformPtr> platforms_;
    // map: deviceID <-> number of last sent message
    QHash<QByteArray, unsigned> sentMessageNumbers_;
    // access to platforms_ and sentMessageNumbers_ should be protected by mutex in case of multithread usage
};
