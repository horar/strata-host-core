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

#include "HostControllerClient.hpp"

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

    Q_PROPERTY(QString data READ data NOTIFY dataChanged)

public:
    Document() {}
    Document(const QString &data) : data_(data) {}
    virtual ~Document() {}

    QString data() const { return data_; }

signals:
    void dataChanged(const QString &name);

private:
    QString data_;
};

using DocumentSet = QList<Document *>;            // typedefs
using DocumentSetPtr = QList<Document *> *;

class DocumentManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QQmlListProperty<Document> schematicDocuments READ schematicDocuments NOTIFY schematicDocumentsChanged)
    Q_PROPERTY(QQmlListProperty<Document> assemblyDocuments READ assemblyDocuments NOTIFY assemblyDocumentsChanged)
    Q_PROPERTY(QQmlListProperty<Document> layoutDocuments READ layoutDocuments NOTIFY layoutDocumentsChanged)
    Q_PROPERTY(QQmlListProperty<Document> testReportDocuments READ testReportDocuments NOTIFY testReportDocumentsChanged)
    Q_PROPERTY(QQmlListProperty<Document> targetedDocuments READ targetedDocuments NOTIFY targetedDocumentsChanged)

public:
    DocumentManager(HCC::HostControllerClient host_controller_client *);
    explicit DocumentManager(QObject *parent);
    virtual ~DocumentManager();

    // read methods
    QQmlListProperty<Document> schematicDocuments() { return QQmlListProperty<Document>(this, schematic_documents_); }
    QQmlListProperty<Document> assemblyDocuments() { return QQmlListProperty<Document>(this, assembly_documents_); }
    QQmlListProperty<Document> layoutDocuments() { return QQmlListProperty<Document>(this, layout_documents_); }
    QQmlListProperty<Document> testReportDocuments() { return QQmlListProperty<Document>(this, test_report_documents_); }
    QQmlListProperty<Document> targetedDocuments() { return QQmlListProperty<Document>(this, targeted_documents_); }

    bool updateDocuments(const QString set, const QList<QString> &documents);

    Q_INVOKABLE bool connectDocumentViewer(const QString &viewer);

signals:
  void schematicDocumentsChanged();
  void assemblyDocumentsChanged();
  void layoutDocumentsChanged();
  void testReportDocumentsChanged();
  void targetedDocumentsChanged();

private:

  // Document Sets
  DocumentSet schematic_documents_;
  DocumentSet assembly_documents_;
  DocumentSet layout_documents_;
  DocumentSet test_report_documents_;
  DocumentSet targeted_documents_;

  std::map<QString, DocumentSetPtr> document_sets;

  DocumentSetPtr getDocumentSet(const QString &set);

  void init();

};

#endif // DOCUMENT_MANAGER_H
