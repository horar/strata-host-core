#ifndef PRTPLATFORMCONNECTOR_H
#define PRTPLATFORMCONNECTOR_H

#include "Flasher.h"

#include <QObject>
#include <QRunnable>
#include <QVariant>

#include <PlatformManager.h>

class PrtModel;

class FlashTask : public QObject, public QRunnable
{
    Q_OBJECT
public:
    FlashTask(spyglass::PlatformConnection *connection, const QString &firmwarePath);
    void run() override;

signals:
    void taskDone(spyglass::PlatformConnection *connector, bool status);
    void notify(QString connectionId, QString message);

private:
    spyglass::PlatformConnection *connection_;
    QString firmwarePath_;
};

class ConnectionHandler : public spyglass::PlatformConnHandler
{
public:
    ConnectionHandler();
    virtual ~ConnectionHandler();

    void setReceiver(PrtModel *receiver);

    virtual void onNewConnection(spyglass::PlatformConnection *connection);
    virtual void onCloseConnection(spyglass::PlatformConnection *connection);
    virtual void onNotifyReadConnection(spyglass::PlatformConnection *connection);

private:
    PrtModel *receiver_;
};

class PrtModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QStringList connectionIds READ connectionIds NOTIFY connectionIdsChanged)

public:
    explicit PrtModel(QObject *parent = nullptr);
    virtual ~PrtModel();

    Q_INVOKABLE void sendCommand(const QString &connectionId, const QString &cmd);
    Q_INVOKABLE void flash(const QString &connectionId, const QString &firmwarePath);

    QStringList connectionIds() const;

    // callbacks from ConnectionHandler
    void newConnection(spyglass::PlatformConnection *connection);
    void closeConnection(spyglass::PlatformConnection *connection);
    void notifyReadConnection(spyglass::PlatformConnection *connection);

signals:
    void connectionIdsChanged();
    void messageArrived(QString connectionId, QString message);
    void notify(QString connectionId, QString message);
    void flashTaskDone(QString connectionId, bool status);

private slots:
    void flasherDoneHandler(spyglass::PlatformConnection *connection, bool status);

private:
    Q_DISABLE_COPY(PrtModel)

    QStringList connectionIds_;
    spyglass::PlatformManager platformManager_;
    ConnectionHandler connectionHandler_;
};

#endif  // PRTPLATFORMCONNECTOR_H
