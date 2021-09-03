#include "DocumentManager.h"

#include "logging/LoggingQtCategories.h"

#include <QObject>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFileInfo>
#include <QDir>
#include <QList>

DocumentManager::DocumentManager(strata::strataRPC::StrataClient *strataClient,
                                 CoreInterface *coreInterface, QObject *parent)
    : QObject(parent), strataClient_(strataClient), coreInterface_(coreInterface)
{
    strataClient_->registerHandler(
        "document_progress",
        std::bind(&DocumentManager::documentProgressHandler, this, std::placeholders::_1));
    strataClient_->registerHandler(
        "document", std::bind(&DocumentManager::loadDocumentHandler, this, std::placeholders::_1));
    strataClient_->registerHandler(
        "platform_meta_data",
        std::bind(&DocumentManager::platformMetaDataHandler, this, std::placeholders::_1));

    init();
}

DocumentManager::~DocumentManager ()
{

}

ClassDocuments *DocumentManager::getClassDocuments(const QString &classId)
{
    if (classes_.contains(classId) == false) {
        ClassDocuments *classDocs = new ClassDocuments(classId, strataClient_, coreInterface_, this);
        classes_[classId] = classDocs;
    }
    else if (classes_[classId]->errorString() != ""){
        classes_[classId]->loadPlatformDocuments();
    }
    return classes_[classId];
}

void DocumentManager::documentProgressHandler(QJsonObject data)
{
    emit updateProgressRequested(data);
}

void DocumentManager::loadDocumentHandler(QJsonObject data)
{
    emit populateModelsRequested(data);
}

void DocumentManager::updateLoadingProgress(QJsonObject data)
{
    QString classId = data["class_id"].toString();

    if (classes_.contains(classId)) {
        classes_[classId]->updateLoadingProgress(data);
    }
}

void DocumentManager::populateModels(QJsonObject data)
{
    QString classId = data["class_id"].toString();

    if (classes_.contains(classId)) {
        classes_[classId]->populateModels(data);
    }

    emit populateModelsFinished(classId);
}

void DocumentManager::platformMetaDataHandler(QJsonObject data)
{
    QString classId = data["class_id"].toString();

    if (classes_.contains(classId)) {
        classes_[classId]->populateMetaData(data);
    }
}

void DocumentManager::init()
{
    /* Due to std::bind(), DocumentManager::viewDocumentHandler() runs in a thread of CoreInterface,
     * which is different from GUI thread.
     * Data manipulation affecting GUI must run in the same thread as GUI.
     * This connection allow us to move data manipulation to the main (GUI) thread.
     */
    connect(this, &DocumentManager::populateModelsRequested, this, &DocumentManager::populateModels);
    connect(this, &DocumentManager::updateProgressRequested, this, &DocumentManager::updateLoadingProgress);
}
