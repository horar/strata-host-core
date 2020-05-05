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
#include <DocumentListModel.h>

class DocumentManager : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(DocumentManager)

    Q_PROPERTY(DownloadDocumentListModel* downloadDocumentListModel READ downloadDocumentListModel CONSTANT)
    Q_PROPERTY(DocumentListModel* datasheetListModel READ datasheetListModel CONSTANT)
    Q_PROPERTY(DocumentListModel* pdfListModel READ pdfListModel CONSTANT)

    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged)

public:
    DocumentManager(CoreInterface *coreInterface, QObject *parent=nullptr);

    virtual ~DocumentManager();

    DownloadDocumentListModel* downloadDocumentListModel();
    DocumentListModel* datasheetListModel();
    DocumentListModel* pdfListModel();

    QString errorString() const;

    Q_INVOKABLE void clearDocuments();

signals:
    void errorStringChanged();
    void populateModelsReguest(QJsonObject data);
    void setPdfModel(QList<DocumentItem*> list);
    void setDatasheetModel(QList<DocumentItem*> list);
    void setDownloadModel(QList<DownloadDocumentItem*> list);

private:
    CoreInterface *coreInterface_;

    void viewDocumentHandler(QJsonObject);

    void populateModels(QJsonObject data);


    DownloadDocumentListModel downloadDocumentModel_;
    DocumentListModel datasheetModel_;
    DocumentListModel pdfModel_;

    QString errorString_;
    void setErrorString(QString errorString);

    void init();

    void populateDatasheetList(const QString &path, QList<DocumentItem* > &list);
};

#endif // DOCUMENT_MANAGER_H
