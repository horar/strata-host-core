#include "core/CoreInterface.h"

#include "LoggingQtCategories.h"

using std::string;

CoreInterface::CoreInterface(strata::strataRPC::StrataClient *strataClient, QObject* parent)
    : QObject(parent)
{
    strataClient_ = strataClient;
    strataClient_->registerHandler("all_platforms", std::bind(&CoreInterface::processAllPlatformsNotification, this, std::placeholders::_1));
    strataClient_->registerHandler("connected_platforms", std::bind(&CoreInterface::processConnectedPlatformsNotification, this, std::placeholders::_1));
    strataClient_->registerHandler("platform_notification", std::bind(&CoreInterface::platformNotificationHandler, this, std::placeholders::_1));

}

CoreInterface::~CoreInterface()
{
    strataClient_->disconnect();    // Move this to SDSModel
}

void CoreInterface::platformNotificationHandler(const QJsonObject &payload)
{
    QJsonDocument doc(payload);
    emit notification(doc.toJson(QJsonDocument::Compact));
}

void CoreInterface::loadDocuments(QString class_id)
{
    auto deferredRequest = strataClient_->sendRequest("load_documents", QJsonObject{{"class_id", class_id}});

    connect(deferredRequest, &strata::strataRPC::DeferredRequest::finishedSuccessfully, this, [&class_id](const QJsonObject &) {
        qCDebug(logCategoryCoreInterface) << "documents for class id:";// << class_id << "requested successfully";
    });

    connect(deferredRequest, &strata::strataRPC::DeferredRequest::finishedWithError, this, [&class_id](const QJsonObject &payload){
        qCCritical(logCategoryCoreInterface) << "Failed to request documents for class id:"; // << class_id << payload;
    });
}

void CoreInterface::sendCommand(QString cmd)
{
    // hcc->sendCmd(cmd.toStdString());
    qCDebug(logCategoryCoreInterface) << "sendCommand" << cmd;
}

void CoreInterface::unregisterClient()
{
    // this is not needed
    QJsonObject cmdMessageObject;
    cmdMessageObject.insert("hcs::cmd", "unregister");
    cmdMessageObject.insert("payload", QJsonObject());

    QJsonDocument doc(cmdMessageObject);
    QString strJson(doc.toJson(QJsonDocument::Compact));
}

bool CoreInterface::registerNotificationHandler(const QString &method, strata::strataRPC::StrataClient::ClientHandler handler)
{
    return strataClient_->registerHandler(method, handler);
}

void CoreInterface::sendRequest(const QString &method, const QJsonObject &payload)
{
    strataClient_->sendRequest(method, payload);
}

void CoreInterface::sendNotification(const QString &method, const QJsonObject &payload)
{
    strataClient_->sendNotification(method, payload);
}

void CoreInterface::processAllPlatformsNotification(const QJsonObject &payload)
{
    QString newPlatformList = QJsonDocument(payload).toJson(QJsonDocument::Compact);
    if (platform_list_ == newPlatformList) {
        return;
    }
    platform_list_ = newPlatformList;
    emit platformListChanged(platform_list_);
}

void CoreInterface::processConnectedPlatformsNotification(const QJsonObject &payload)
{
    QString newConnectedPlatformList = QJsonDocument(payload).toJson(QJsonDocument::Compact);
    if (connected_platform_list_ == newConnectedPlatformList) {
        return;
    }
    connected_platform_list_ = newConnectedPlatformList;
    emit connectedPlatformListChanged(connected_platform_list_);
}
