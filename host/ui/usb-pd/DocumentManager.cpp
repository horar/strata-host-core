//
// author: ian
// date: 25 October 2017
//
// Document Manager class to interact with corresponding QML SGDocumentViewer Widget
//

#include <QObject>
#include <QJsonObject>
#include <QJsonArray>

#include "DocumentManager.h"

DocumentManager::DocumentManager()
{
    qDebug("DocumentManager::DocumentManager() default ctor");
}

DocumentManager::DocumentManager(QObject *parent) : QObject(parent)
{
    qDebug("DocumentManager::DocumentManager(parent=%p)", parent);
}

DocumentManager::~DocumentManager ()
{
    // TODO free all documents

}

//
// @f simulateNewDocuments
// @b debug
void DocumentManager::simulateNewDocuments ()
{
    qDebug("DocumentManager::simulateNewDocuments: DISABLED");
    std::string g_document=R"({"data":"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"})";
    //updateDocuments ("schematic", QString(g_document.c_str ()));
}

QQmlListProperty<Document> DocumentManager::documents()
{
    return QQmlListProperty<Document>(this, documents_);
}

void DocumentManager::registerDocumentViewer(const QString &object_name)
{
    //QObject *qmlObject = rootObject->findChild<QObject*>("mainWindow");
    qDebug("DocumentManager::registerDocumentViewer('%s')", object_name.toStdString ().c_str ());
}

// json: {"name":"<name", "data":"<base64 image data>"}
void DocumentManager::updateDocuments(const QString viewer, const QList<QString> &documents)
{

#if NON_IMAGE_DATA_INTEGRITY_TESTING
    int document_count = 0;
    qDebug("============== INCOMING:START document_count = %d ===============", document_count);
#endif

    qDebug() << "DocumentManager::updateDocuments() called";
    documents_.clear ();  // clear out old documents
    for( auto &document : documents) {

#if NON_IMAGE_DATA_INTEGRITY_TESTING
        qDebug("count=%d, data = %s", document_count, document.toStdString ().c_str ());
        document_count++;
#endif

        QJsonDocument json_doc = QJsonDocument::fromJson(document.toUtf8());
        if (!json_doc.isObject()) {
            qCritical("JSON invalid. '%s'", document.toStdString ().c_str ());
            return;
        }

        QJsonObject json = json_doc.object();
        QString data = json["data"].toString ();

        Document *d = new Document (data);
        documents_.append (d);
    }

#if NON_IMAGE_DATA_INTEGRITY_TESTING
    qDebug("============== INCOMING:END document_count = %d ===============", document_count);
    // DEBUG assure I'm putting data in Documents
    qDebug("============== DOCUMENT_MANAGER:start document_count = %d ===============", documents_.length ());
    int count = 0;
    for( auto &v : documents_) {
        qDebug("DocumentManager::updateDocuments: count: %d, data = %s", count, v->data().toStdString ().c_str ());
        count++;
    }
    qDebug("============== DOCUMENT_MANAGER:end document_count = %d ===============", documents_.length ());
#endif

    emit documentsChanged();
}

#if SAVE_FOR_LATER

void DocumentManager::updateDocuments(const QString &documents)
{
    qDebug("udpateDocuments(). json='%s'", documents.toStdString ().c_str ());

    //      "documents": [
    //             {"name":"<name>", "data":"<base64 data>"},
    //             {"name":"<name>", "data":"<base64 data>"},
    //             {"name":"<name>", "data":"<base64 data>"},
    //                 ...
    //      ]

    QJsonDocument json_doc = QJsonDocument::fromJson(documents.toUtf8());
    if (!json_doc.isObject()) {
        qCritical("JSON invalid. '%s'", documents.toStdString ().c_str ());
        return;
    }

    QJsonObject json = json_doc.object();
    QJsonArray documents_array = json["documents"].toArray();;

    foreach (const QJsonValue &value, documents_array ) {
        QJsonObject document_json = value.toObject();

        const QString name = document_json["name"].toString ();
        const QString data = document_json["data"].toString ();

        // obviously don't print the base64 image data
        qDebug("JSON: document: name=%s", name.toStdString ().c_str ());

        Document *doc = new Document;
        if( doc == nullptr ) {
            qCritical("ERR: unable to allocate new Document");
            return;
        }

        // use set accessor incase an QML UI element is binding directly to the document
        //   the set() method will emit the correct signal
        doc->set (name, data);
        documents_.append (doc);
    }

    emit documentsChanged();  // if using property system
}
#endif
