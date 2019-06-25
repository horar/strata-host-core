#include "SciModel.h"
#include "logging/LoggingQtCategories.h"
#include <PlatformConnection.h>

SciModel::SciModel(QObject *parent)
    : QObject(parent)
{
    boardController_.initialize();

    connect(&flasherConnector_, &FlasherConnector::taskDone,
            this, &SciModel::programDeviceDoneHandler);

    connect(&flasherConnector_, &FlasherConnector::notify,
            this, &SciModel::notify);
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

    flasherConnector_.start(connection, firmwarePath);
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
