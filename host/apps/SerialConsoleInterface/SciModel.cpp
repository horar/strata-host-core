#include "SciModel.h"
#include "PlatformBoard.h"
#include "ProgramDeviceTask.h"
#include "logging/LoggingQtCategories.h"
#include <PlatformConnection.h>

#include <QThreadPool>

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
    qCInfo(logCategorySci) << connectionId << firmwarePath;

    spyglass::PlatformConnectionShPtr connection = boardController_.getConnection(connectionId);
    if (connection == nullptr) {
        qCWarning(logCategorySci) << "unknown connection id" << connectionId;
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

BoardsController *SciModel::boardController()
{
    return &boardController_;
}

SgJLinkConnector *SciModel::jLinkConnector()
{
    return &jLinkConnector_;
}

void SciModel::programDeviceDoneHandler(const QString& connectionId, bool status)
{
    emit programDeviceDone(connectionId, status);
}
