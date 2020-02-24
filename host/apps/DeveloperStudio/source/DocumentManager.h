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

    Q_PROPERTY(uint pdfRevisionCount MEMBER pdf_rev_count_ NOTIFY pdfRevisionCountChanged)
    Q_PROPERTY(uint downloadRevisionCount MEMBER download_rev_count_ NOTIFY downloadRevisionCountChanged)
    Q_PROPERTY(uint datasheetRevisionCount MEMBER datasheet_rev_count_ NOTIFY datasheetRevisionCountChanged)

    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged)

public:
    DocumentManager(CoreInterface *coreInterface, QObject *parent=nullptr);

    virtual ~DocumentManager();

    DownloadDocumentListModel* downloadDocumentListModel();
    DocumentListModel* datasheetListModel();
    DocumentListModel* pdfListModel();

    QString errorString();

    Q_INVOKABLE void clearPdfRevisionCount();
    Q_INVOKABLE void clearDownloadRevisionCount();
    Q_INVOKABLE void clearDatasheetRevisionCount();
    Q_INVOKABLE void clearDocuments();

signals:
    void errorStringChanged();
    void populateModelsReguest(QJsonObject data);

    // Revision Count Changes
    void pdfRevisionCountChanged(uint revisionCount);
    void downloadRevisionCountChanged(uint revisionCount);
    void datasheetRevisionCountChanged(uint revisionCount);

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

    // Count the amount of deployments that have been received
    uint pdf_rev_count_;
    uint download_rev_count_;
    uint datasheet_rev_count_;

    QString errorString_;
    void setErrorString(QString errorString);

    void init();

    void populateDatasheedList(const QString &path, QList<DocumentItem* > &list);
};

#endif // DOCUMENT_MANAGER_H
