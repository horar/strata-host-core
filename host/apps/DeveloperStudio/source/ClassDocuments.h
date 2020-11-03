#ifndef CLASSDOCUMENTS_H
#define CLASSDOCUMENTS_H

#include <QObject>
#include <QList>
#include <QString>
#include <QDebug>
#include <QJsonObject>
#include <PlatformInterface/core/CoreInterface.h>
#include "DownloadDocumentListModel.h"
#include <DocumentListModel.h>
#include <VersionedListModel.h>

class ClassDocuments : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(ClassDocuments)


    Q_PROPERTY(DownloadDocumentListModel* downloadDocumentListModel READ downloadDocumentListModel CONSTANT)
    Q_PROPERTY(DocumentListModel* datasheetListModel READ datasheetListModel CONSTANT)
    Q_PROPERTY(VersionedListModel* firmwareListModel READ firmwareListModel CONSTANT)
    Q_PROPERTY(VersionedListModel* controlViewListModel READ controlViewListModel CONSTANT)
    Q_PROPERTY(DocumentListModel* pdfListModel READ pdfListModel CONSTANT)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)
    Q_PROPERTY(int loadingProgressPercentage READ loadingProgressPercentage NOTIFY loadingProgressPercentageChanged)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged)
    Q_PROPERTY(bool initialized READ initialized NOTIFY initializedChanged)
    Q_PROPERTY(bool metaDataInitialized READ metaDataInitialized NOTIFY metaDataInitializedChanged)


public:
    explicit ClassDocuments(QString classId, CoreInterface *coreInterface, QObject *parent = nullptr);

    DownloadDocumentListModel* downloadDocumentListModel();
    DocumentListModel* datasheetListModel();
    DocumentListModel* pdfListModel();
    VersionedListModel* firmwareListModel();
    VersionedListModel* controlViewListModel();

    QString errorString() const;
    bool loading() const;
    bool initialized() const;
    bool metaDataInitialized() const;
    int loadingProgressPercentage() const;

    Q_INVOKABLE void loadPlatformDocuments();
    Q_INVOKABLE void clearDocuments();

    void updateLoadingProgress(QJsonObject data);
    void populateModels(QJsonObject data);
    void populateMetaData(QJsonObject data);

signals:
    void errorStringChanged();
    void loadingChanged();
    void loadingProgressPercentageChanged();
    void initializedChanged();
    void metaDataInitializedChanged();

private slots:

//    void updateLoadingProgress(QJsonObject data);

private:
    QString classId_;
    CoreInterface *coreInterface_;
    DownloadDocumentListModel downloadDocumentModel_;
    DocumentListModel datasheetModel_;
    DocumentListModel pdfModel_;
    VersionedListModel firmwareModel_;
    VersionedListModel controlViewModel_;

    QString errorString_;
    bool loading_ = false;
    bool initialized_ = false;
    bool metaDataInitialized_ = false;
    int loadingProgressPercentage_ = 0;

    void setErrorString(QString errorString);
    void setLoading(bool loading);
    void setInitialized(bool initialized);
    void setMetaDataInitialized(bool init);
    void setLoadingProgressPercentage(int loadingProgressPercentage);
    void populateDatasheetList(const QString &path, QList<DocumentItem* > &list);
};

#endif // CLASSDOCUMENTS_H
