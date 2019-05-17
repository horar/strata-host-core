#include "SciModel.h"
#include "PlatformBoard.h"
#include "ProgramDeviceTask.h"

#include <PlatformConnection.h>

#include <QDebug>
#include <QThreadPool>
#include <QFileInfo>
#include <QUrl>



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
    spyglass::PlatformConnectionShPtr connection = boardController_.getConnection(connectionId);
    if (connection == nullptr) {
        notify(connectionId, "Connection Id not valid.");
        programDeviceDone(connectionId, false);
        return;
    }

    ProgramDeviceTask *task = new ProgramDeviceTask(connection, firmwarePath);
    connect(task, &ProgramDeviceTask::taskDone,
            this, &SciModel::programDeviceDoneHandler);

    connect(task, &ProgramDeviceTask::notify,
            this, &SciModel::notify);

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

void SciModel::programDeviceDoneHandler(const QString& connectionId, bool status)
{
    emit programDeviceDone(connectionId, status);
}
