//
// author: ian
// date: 25 October 2017
//
// Document Manager class to interact with corresponding QML SGDocumentViewer Widget
//
#ifndef DOCUMENT_MANAGER_H
#define DOCUMENT_MANAGER_H

#include <QQmlListProperty>
#include <QObject>
#include <QByteArray>
#include <QList>
#include <QString>
#include <QDebug>
#include <QJsonObject>
#include <QJsonDocument>
#include <QMetaObject>
#include <QQmlEngine>
#include <PlatformInterface/core/CoreInterface.h>

// Note: adding document set

// 3) Create DocumentSet <name>_documents_;  // class memmber
// 4) add Q_PROPERTY(QmlListProperty<Document> <name>Documents READ <name>Documents NOTIFY <name>DocumentsChanged
// 5) add <name>Documents() READ implementation
//      eg:
//   QQmlListProperty<Document> DocumentManager::<name>Documents() { return QQmlListProperty<Document>(this, <name>_documents_); }
// 6) add signal definition to class.  void <name>DocumentsChanged();
//
//

class Document : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString uri READ uri NOTIFY uriChanged)
    Q_PROPERTY(QString filename READ filename NOTIFY filenameChanged)
    Q_PROPERTY(QString dirname READ dirname NOTIFY dirnameChanged)

public:
    Document() {}
    Document(const QString &uri, const QString &filename, const QString &dirname) : uri_(uri), filename_(filename), dirname_(dirname) {}
    virtual ~Document() {}

    QString uri() const { return uri_; }
    QString filename() const { return filename_; }
    QString dirname() const { return dirname_; }

signals:
    void uriChanged(const QString &name);
    void filenameChanged(const QString &filename);
    void dirnameChanged(const QString &dirname);

private:
    QString uri_;
    QString filename_;
    QString dirname_;
};

using DocumentSet = QList<Document *>;            // typedefs
using DocumentSetPtr = QList<Document *> *;

class DocumentManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QQmlListProperty<Document> pdfDocuments READ pdfDocuments NOTIFY pdfDocumentsChanged)
    Q_PROPERTY(QQmlListProperty<Document> downloadDocuments READ downloadDocuments NOTIFY downloadDocumentsChanged)
    Q_PROPERTY(QQmlListProperty<Document> datasheetDocuments READ datasheetDocuments NOTIFY datasheetDocumentsChanged)

    Q_PROPERTY(uint pdfRevisionCount MEMBER pdf_rev_count_ NOTIFY pdfRevisionCountChanged)
    Q_PROPERTY(uint downloadRevisionCount MEMBER download_rev_count_ NOTIFY downloadRevisionCountChanged)
    Q_PROPERTY(uint datasheetRevisionCount MEMBER datasheet_rev_count_ NOTIFY datasheetRevisionCountChanged)

public:
    DocumentManager();
    DocumentManager(CoreInterface *coreInterface);
    explicit DocumentManager(QObject *parent);
    virtual ~DocumentManager();

    // read methods
    QQmlListProperty<Document> pdfDocuments() { return QQmlListProperty<Document>(this, pdf_documents_); }
    QQmlListProperty<Document> downloadDocuments() { return QQmlListProperty<Document>(this, download_documents_); }
    QQmlListProperty<Document> datasheetDocuments() { return QQmlListProperty<Document>(this, datasheet_documents_); }

    bool updateDocuments(const QString set, const QList<QString> &documents);

    Q_INVOKABLE void clearPdfRevisionCount();
    Q_INVOKABLE void clearDownloadRevisionCount();
    Q_INVOKABLE void clearDatasheetRevisionCount();

    Q_INVOKABLE void clearDocumentSets();

signals:
    // Document Changes
    void pdfDocumentsChanged();
    void downloadDocumentsChanged();
    void datasheetDocumentsChanged();
    // Any Changed
    void documentsUpdated();

    // Revision Count Changes
    void pdfRevisionCountChanged(uint revisionCount);
    void downloadRevisionCountChanged(uint revisionCount);
    void datasheetRevisionCountChanged(uint revisionCount);

private:
    CoreInterface *coreInterface_;

    void viewDocumentHandler(QJsonObject);

    // Document Sets
    DocumentSet pdf_documents_;
    DocumentSet download_documents_;
    DocumentSet datasheet_documents_;

    std::map<QString, DocumentSetPtr> document_sets_;

    DocumentSetPtr getDocumentSet(const QString &set);

    // Count the amount of deployments that have been received
    uint pdf_rev_count_;
    uint download_rev_count_;
    uint datasheet_rev_count_;

    void init();
};

#endif // DOCUMENT_MANAGER_H
