#include "PrtModel.h"

#include <QDebug>
#include <QTemporaryFile>
#include <QThreadPool>

#include <PlatformConnection.h>

FlashTask::FlashTask(spyglass::PlatformConnection *connection, const QString &firmwarePath)
    : connection_(connection), firmwarePath_(firmwarePath)
{
}

void FlashTask::run()
{
    if(connection_ == nullptr) {
        emit taskDone(connection_, false);
        return;
    }

    Flasher flasher(connection_, firmwarePath_.toStdString());

    emit notify(QString::fromStdString(connection_->getName()), "Initializing bootloader.\n");

    if (flasher.initializeBootloader()) {
        emit notify(QString::fromStdString(connection_->getName()), "Flashing.\n");
        if (flasher.flash(true)) {
            emit taskDone(connection_, true);
            return;
        }
    } else {
        emit notify(QString::fromStdString(connection_->getName()), "Initializing of bootloader failed.\n");
    }

    emit taskDone(connection_, false);
}

PrtModel::PrtModel(QObject *parent)
    : QObject(parent)
{
    connectionHandler_.setReceiver(this);

    if (platformManager_.Init()) {
        platformManager_.setPlatformHandler(&connectionHandler_);
        platformManager_.StartLoop();
    } else {
        //TODO: notify user
        qDebug() << "PrtModel::PrtModel() Initialization of platform manager failed.";
    }
}

PrtModel::~PrtModel()
{
    platformManager_.Stop();
}

void PrtModel::sendCommand(const QString &connectionId, const QString &cmd)
{
    spyglass::PlatformConnection *connection = platformManager_.getConnection(connectionId.toStdString());

    if (connection == nullptr) {
        return;
    }

    connection->sendMessage(cmd.toStdString());
}

void PrtModel::flasherDoneHandler(spyglass::PlatformConnection *connection, bool status)
{
    QString connectionId = QString::fromStdString(connection->getName());
    emit flashTaskDone(connectionId, status);
}

void PrtModel::flash(const QString &connectionId, const QString &firmwarePath)
{
    spyglass::PlatformConnection *connection = platformManager_.getConnection(connectionId.toStdString());

    if (connection == nullptr) {
        notify(connectionId, "Connection Id not valid.");
        flashTaskDone(connectionId, false);
        return;
    }

    FlashTask *task = new FlashTask(connection, firmwarePath);
    connect(task, SIGNAL(taskDone(spyglass::PlatformConnection *, bool)),
            this, SLOT(flasherDoneHandler(spyglass::PlatformConnection *, bool)));

    connect(task, SIGNAL(notify(QString, QString)),
            this, SIGNAL(notify(QString, QString)));

    QThreadPool::globalInstance()->start(task);
}

QStringList PrtModel::connectionIds() const
{
    return connectionIds_;
}

void PrtModel::newConnection(spyglass::PlatformConnection *connection)
{
    QString connectionId = QString::fromStdString(connection->getName());

    if (connectionIds_.indexOf(connectionId) < 0) {
        connectionIds_.append(connectionId);
        emit connectionIdsChanged();
    } else {
        qDebug() << "ERROR: this board is already connected" << connectionId;
    }
}

void PrtModel::closeConnection(spyglass::PlatformConnection *connection)
{
    QString connectionId = QString::fromStdString(connection->getName());

    int ret = connectionIds_.removeAll(connectionId);
    emit connectionIdsChanged();

    if (ret != 1) {
        qDebug() << "ERROR: suspicious number of boards removed" << connectionId << ret;
    }
}

void PrtModel::notifyReadConnection(spyglass::PlatformConnection *connection)
{
    std::string message;
    connection->getMessage(message);

    emit messageArrived(QString::fromStdString(connection->getName()),
                        QString::fromStdString(message));
}

ConnectionHandler::ConnectionHandler() : receiver_(nullptr)
{
}

ConnectionHandler::~ConnectionHandler()
{
}

void ConnectionHandler::setReceiver(PrtModel *receiver)
{
    receiver_ = receiver;
}

void ConnectionHandler::onNewConnection(spyglass::PlatformConnection *connection)
{
    if (receiver_ != nullptr) {
        receiver_->newConnection(connection);
    }
}

void ConnectionHandler::onCloseConnection(spyglass::PlatformConnection *connection)
{
    if (receiver_ != nullptr) {
        receiver_->closeConnection(connection);
    }
}

void ConnectionHandler::onNotifyReadConnection(spyglass::PlatformConnection *connection)
{
    if (receiver_ != nullptr) {
        receiver_->notifyReadConnection(connection);
    }
}
