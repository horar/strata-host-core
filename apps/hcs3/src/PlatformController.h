/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
     * PlatformController destructor
     */
    virtual ~PlatformController();

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

public slots:
    void bootloaderActive(QByteArray deviceId);
    void applicationActive(QByteArray deviceId);

signals:
    void platformConnected(QByteArray deviceId);
    void platformDisconnected(QByteArray deviceId);
    void platformMessage(QString platformId, QJsonObject message);

private slots:  // slots for signals from PlatformManager
    void newConnection(const QByteArray& deviceId, bool recognized, bool inBootloader);
    void closeConnection(const QByteArray& deviceId);
    void messageFromPlatform(strata::platform::PlatformMessage message);
    void messageToPlatform(QByteArray rawMessage, unsigned msgNumber, QString errorString);

private:
    struct PlatformData {
        PlatformData(strata::platform::PlatformPtr p, bool b);

        strata::platform::PlatformPtr platform;
        bool inBootloader;
        unsigned sentMessageNumber;  // number of last sent message
    };

    strata::PlatformManager platformManager_;

    // map: deviceID <-> PlatformData
    QHash<QByteArray, PlatformData> platforms_;
    // access to platforms_ should be protected by mutex in case of multithread usage
};
