#ifndef PLATFORMCONTROLLER_H
#define PLATFORMCONTROLLER_H

#include "Connector.h"

#include <QObject>
#include <thread>
#include <shared_mutex>
#include <memory>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>

class PlatformController:public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool platformConnected READ platformConnected WRITE setPlatformConnected NOTIFY platformConnectedChanged)
    Q_PROPERTY(QString notification READ notification WRITE setNotification NOTIFY notificationChanged)
    Q_PROPERTY(QString verboseName READ verboseName WRITE setVerboseName NOTIFY verboseNameChanged)
    Q_PROPERTY(QString platformID READ platformID WRITE setPlatformID NOTIFY platformIDChanged)

public:
    explicit PlatformController(QObject *parent = nullptr);
    virtual ~PlatformController();

    Q_INVOKABLE void initializePlatform();
    Q_INVOKABLE void sendCommand(QString cmd, QString platformID);

    QString verboseName() const;
    QString platformID() const;
    QString notification() const;
    bool platformConnected() const;

public slots:
    void setPlatformConnected(bool platformConnected);
    void setVerboseName(QString verboseName);
    void setPlatformID(QString platformID);
    void setNotification(QString notification);

signals:
    void platformConnectedChanged(QString payload);
    void verboseNameChanged(QString verboseName);
    void platformIDChanged(QString platformID);
    void notificationChanged(QString notification, QString platformID);

private:
    void readWorker();
    void connectWorker();

    static std::string toString(const QString& s);
    static QString toQString(const std::string &s);

    std::unique_ptr<Connector> serial_;
    std::thread reader_;
    std::thread connector_;
    std::shared_mutex quitMutex_;
    bool platformConnected_;
    QString verboseName_;
    QString platformID_;
    QString notification_;
    QJsonObject payload_;
    QJsonArray platformCommands_;
    bool aboutToQuit_;
};

#endif // PLATFORMCONTROLLER_H
