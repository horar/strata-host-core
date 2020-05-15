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
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)
    Q_PROPERTY(int loadingProgressPercentage READ loadingProgressPercentage NOTIFY loadingProgressPercentageChanged)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged)

public:
    DocumentManager(CoreInterface *coreInterface, QObject *parent=nullptr);

    virtual ~DocumentManager();

    DownloadDocumentListModel* downloadDocumentListModel();
    DocumentListModel* datasheetListModel();
    DocumentListModel* pdfListModel();

    QString errorString() const;
    bool loading() const;
    int loadingProgressPercentage() const;

    Q_INVOKABLE void loadPlatformDocuments(const QString &classId);
    Q_INVOKABLE void clearDocuments();

signals:
    void errorStringChanged();
    void loadingChanged();
    void loadingProgressPercentageChanged();
    void updateProgressRequested(QJsonObject data);
    void populateModelsRequested(QJsonObject data);
    void setPdfModel(QList<DocumentItem*> list);
    void setDatasheetModel(QList<DocumentItem*> list);
    void setDownloadModel(QList<DownloadDocumentItem*> list);

private slots:
    void documentProgressHandler(QJsonObject data);
    void loadDocumentHandler(QJsonObject data);

    void updateLoadingProgress(QJsonObject data);
    void populateModels(QJsonObject data);

private:
    CoreInterface *coreInterface_;
    DownloadDocumentListModel downloadDocumentModel_;
    DocumentListModel datasheetModel_;
    DocumentListModel pdfModel_;

    QString errorString_;
    bool loading_ = false;
    int loadingProgressPercentage_ = 0;

    void setErrorString(QString errorString);
    void setLoading(bool loading);
    void setLoadingProgressPercentage(int loadingProgressPercentage);
    void init();
    void populateDatasheetList(const QString &path, QList<DocumentItem* > &list);
};

#endif // DOCUMENT_MANAGER_H
