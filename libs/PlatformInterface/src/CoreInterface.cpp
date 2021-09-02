#include "core/CoreInterface.h"
#include "LoggingQtCategories.h"

#include <QJsonDocument>

CoreInterface::CoreInterface(strata::strataRPC::StrataClient *strataClient, QObject *parent)
    : QObject(parent), strataClient_(strataClient)
{
    strataClient_->registerHandler(
        "all_platforms",
        std::bind(&CoreInterface::processAllPlatformsNotification, this, std::placeholders::_1));
    strataClient_->registerHandler("connected_platforms",
                                   std::bind(&CoreInterface::processConnectedPlatformsNotification,
                                             this, std::placeholders::_1));
    strataClient_->registerHandler(
        "platform_notification",
        std::bind(&CoreInterface::processPlatformNotification, this, std::placeholders::_1));
    strataClient_->registerHandler(
        "updates_available", std::bind(&CoreInterface::processUpdatesAvailableNotification, this,
                                       std::placeholders::_1));
    strataClient_->registerHandler(
        "update_firmware_job", std::bind(&CoreInterface::processUpdateFirmwareJobNotification, this,
                                         std::placeholders::_1));
}

CoreInterface::~CoreInterface()
{
}

void CoreInterface::processPlatformNotification(const QJsonObject &payload)
{
    QJsonDocument doc(payload);
    emit notification(doc.toJson(QJsonDocument::Compact));
}

void CoreInterface::sendCommand(const QString &)
{
    qCCritical(logCategoryCoreInterface) << "Deprecated method.";
}

void CoreInterface::sendNotification(const QString &method, const QJsonObject &payload)
{
    strataClient_->sendNotification(method, payload);
}

void CoreInterface::processAllPlatformsNotification(const QJsonObject &payload)
{
    QString newPlatformList = QJsonDocument(payload).toJson(QJsonDocument::Compact);
    if (platformList_ != newPlatformList) {
        platformList_ = newPlatformList;
    }
    emit platformListChanged(platformList_);
}

void CoreInterface::processConnectedPlatformsNotification(const QJsonObject &payload)
{
    QString newConnectedPlatformList = QJsonDocument(payload).toJson(QJsonDocument::Compact);
    if (connectedPlatformList_ == newConnectedPlatformList) {
        return;
    }
    connectedPlatformList_ = newConnectedPlatformList;
    emit connectedPlatformListChanged(connectedPlatformList_);
}

void CoreInterface::processUpdatesAvailableNotification(const QJsonObject &payload)
{
    emit updateInfoReceived(payload);
}

void CoreInterface::processDownloadViewFinishedNotification(const QJsonObject &payload)
{
    emit downloadViewFinished(payload);
}

void CoreInterface::processDownloadControlViewProgressNotification(const QJsonObject &payload)
{
    emit downloadControlViewProgress(payload);
}

void CoreInterface::processUpdateFirmwareJobNotification(const QJsonObject &payload)
{
    emit updateFirmwareJobUpdate(payload);
}