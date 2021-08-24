#pragma once

#include <StrataRPC/StrataClient.h>
#include <QJsonObject>
#include <QObject>
#include <QString>

class CoreInterface : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(CoreInterface)
    Q_PROPERTY(QString platformList_ READ platformList NOTIFY platformListChanged)
    Q_PROPERTY(QString connectedPlatformList_ READ connectedPlatformList NOTIFY
                   connectedPlatformListChanged)

public:
    /**
     * CoreInterface constructor
     * @param [in] strataClient pointer to strataClient
     */
    explicit CoreInterface(strata::strataRPC::StrataClient *strataClient,
                           QObject *parent = nullptr);

    /**
     * CoreInterface destructor
     */
    virtual ~CoreInterface();

    /**
     * Function to send commands to platforms
     * @param [in] cmd platform command in json string format
     * @note This is a deprecated function and left here for API compatibility with older views.
     */
    Q_INVOKABLE void sendCommand(const QString &cmd);

    /**
     * Function to send notifications to HCS
     * @param [in] handler The handler name in StrataServer.
     * @param [in] payload QJsonObject of the request payload.
     */
    Q_INVOKABLE void sendNotification(const QString &handler, const QJsonObject &payload);

    /**
     * Function to access PlatformList_
     * @return QString of all platform list.
     */
    QString platformList() const
    {
        return platformList_;
    }

    /**
     * Function to access connectedPlatformList_
     * @return QString of all connected platforms.
     */
    QString connectedPlatformList() const
    {
        return connectedPlatformList_;
    }

signals:
    /**
     * Signal emitted when platformList_ is updated.
     * @param [in] platformList QString of the all platform
     */
    void platformListChanged(const QString &platformList);

    /**
     * Signal emitted when connectedPlatformList_ is updated.
     * @param [in] connectedPlatformList QString of the all connected platforms
     */
    bool connectedPlatformListChanged(const QString &connectedPlatformList);

    /**
     * Signal emitted when a platform notification is received
     * @param [in] payload QString of the platform notification that contains the
     * device_it and the notification.
     */
    void notification(const QString &payload);

private:
    void processPlatformNotification(const QJsonObject &payload);
    void processAllPlatformsNotification(const QJsonObject &payload);
    void processConnectedPlatformsNotification(const QJsonObject &payload);

    strata::strataRPC::StrataClient *strataClient_{nullptr};
    QString platformList_{"{ \"list\":[]}"};
    QString connectedPlatformList_{"{ \"list\":[]}"};
};
