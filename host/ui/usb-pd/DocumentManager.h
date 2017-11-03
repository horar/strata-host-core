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

class DocumentManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<Document> documents READ documents NOTIFY documentsChanged)

public:
    DocumentManager();
    explicit DocumentManager(QObject *parent);
    virtual ~DocumentManager();

    QQmlListProperty<Document> documents();  // read method for Q_PROPERTY

    Q_INVOKABLE void registerDocumentViewer(const QString &object_name);
    Q_INVOKABLE void simulateNewDocuments();

    void updateDocuments(const QString viewer, const QList<QString> &documents);

signals:
  void documentsChanged();

private:
    QList<Document *> documents_;

};







#endif // DOCUMENT_MANAGER_H
