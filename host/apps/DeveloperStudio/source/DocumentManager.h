//
// author: ian
// date: 25 October 2017
//
// Document Manager class to interact with corresponding QML SGDocumentViewer Widget
//
#ifndef DOCUMENT_MANAGER_H
#define DOCUMENT_MANAGER_H

#include <QObject>
#include <QList>
#include <QString>
#include <QDebug>
#include <QJsonObject>
#include <PlatformInterface/core/CoreInterface.h>
#include "DownloadDocumentListModel.h"
#include "ClassDocuments.h"
#include <DocumentListModel.h>
#include <QMap>

class DocumentManager : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(DocumentManager)

public:
    DocumentManager(CoreInterface *coreInterface, QObject *parent=nullptr);

    virtual ~DocumentManager();

    Q_INVOKABLE ClassDocuments* getClassDocuments(const QString &classId);

    QMap<QString, ClassDocuments*> classes_;

signals:
    void updateProgressRequested(QJsonObject data);
    void populateModelsRequested(QJsonObject data);
    void populateModelsFinished(QString classId);
    void populateMetaDataFinished(QString classId);

private slots:
    void documentProgressHandler(QJsonObject data);
    void loadDocumentHandler(QJsonObject data);

    void updateLoadingProgress(QJsonObject data);
    void populateModels(QJsonObject data);
    void platformDocumentsMetaDataHandler(QJsonObject data);

private:
    CoreInterface *coreInterface_;

    void init();
};

#endif // DOCUMENT_MANAGER_H
