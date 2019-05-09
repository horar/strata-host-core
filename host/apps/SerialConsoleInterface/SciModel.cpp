#include "SciModel.h"
#include <PlatformConnection.h>
#include "PlatformBoard.h"

#include <QDebug>
#include <QThreadPool>
#include <QFileInfo>
#include <QUrl>

ProgramDeviceTask::ProgramDeviceTask(spyglass::PlatformConnection *connection, const QString &firmwarePath)
    : connection_(connection), firmwarePath_(firmwarePath)
{
}

void ProgramDeviceTask::run()
{
    if (connection_ == nullptr) {
        emit taskDone(connection_, false);
        return;
    }

    Flasher flasher(connection_, firmwarePath_.toStdString());

    emit notify(QString::fromStdString(connection_->getName()), "Initializing bootloader");

    if (flasher.initializeBootloader()) {
        emit notify(QString::fromStdString(connection_->getName()), "Programming");
        if (flasher.flash(true)) {
            emit taskDone(connection_, true);
            return;
        }
    } else {
        emit notify(QString::fromStdString(connection_->getName()), "Initializing of bootloader failed");
    }

    emit taskDone(connection_, false);
}

SciModel::SciModel(QObject *parent)
    : QObject(parent)
{
    boardController_.initialize();
}

SciModel::~SciModel()
{
}

void SciModel::programDevice(const QString &connectionId, const QString &firmwarePath)
{
    qDebug() << "SciModel::programDevice()" << connectionId << firmwarePath;
    spyglass::PlatformConnection *connection = boardController_.getConnection(connectionId);
    if (connection == nullptr) {
        notify(connectionId, "Connection Id not valid.");
        programDeviceDone(connectionId, false);
        return;
    }

    ProgramDeviceTask *task = new ProgramDeviceTask(connection, firmwarePath);
    connect(task, SIGNAL(taskDone(spyglass::PlatformConnection *, bool)),
            this, SLOT(programDeviceDoneHandler(spyglass::PlatformConnection *, bool)));

    connect(task, SIGNAL(notify(QString, QString)),
            this, SIGNAL(notify(QString, QString)));

    QThreadPool::globalInstance()->start(task);
}

QString SciModel::urlToPath(const QUrl &url)
{
    return QUrl(url).path();
}

bool SciModel::isFile(const QString &file)
{
    QFileInfo info(file);
    return info.isFile();
}

BoardsController *SciModel::boardController()
{
    return &boardController_;
}

void SciModel::programDeviceDoneHandler(spyglass::PlatformConnection *connection, bool status)
{
    QString connectionId = QString::fromStdString(connection->getName());
    emit programDeviceDone(connectionId, status);
}
