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

using namespace std;

DocumentManager::DocumentManager()
{
    //qDebug("DocumentManager::DocumentManager() default ctor");
    init();
}

DocumentManager::DocumentManager(QObject *parent) : QObject(parent)
{
    //qDebug("DocumentManager::DocumentManager(parent=%p)", parent);
    init();
}

DocumentManager::~DocumentManager ()
{
    // TODO free all documents

}

void DocumentManager::init()
{
    //qDebug("DocumentManager::init");

    // create document sets: "<name>",  & <name>_documnts_
    document_sets.emplace(make_pair(QString("schematic"), &schematic_documents_));
    document_sets.emplace(make_pair(QString("assembly"), &assembly_documents_));
    document_sets.emplace(make_pair(QString("layout"), &layout_documents_));
    document_sets.emplace(make_pair(QString("test_report"), &test_report_documents_));
    document_sets.emplace(make_pair(QString("targeted_content"), &targeted_documents_));

}

// @f getDocumentSet
// @b get document set by name
//
// arguments:
//  IN:
//   set : document set name
//
//  OUT:
//   document set requested
//
//  ERROR:
//    returns nullptr if document set cannot be found
//
DocumentSetPtr DocumentManager::getDocumentSet(const QString &set)
{
    auto document_set = document_sets.find(set.toStdString ().c_str ());
    if (document_set == document_sets.end()) {
        qDebug("DocumentManager::getDocumentSet: %s NOT FOUND)", set.toStdString ().c_str ());
        return nullptr;
    }

    return document_set->second;
}

// @f updateDocuments
// @b called by InterfaceImplementationBinding to update document set for viewer
//
// arguments:
// IN:
//   viewer : document viewer to update "schematic", "assembly", "test_report"
//   documents <json format>: QList[ {"data":"<base64 image data>"} ]
//
// OUT: bool error
//
bool DocumentManager::updateDocuments(const QString set, const QList<QString> &documents)
{

    qDebug() << "DocumentManager::updateDocuments(" << set << ")";

    DocumentSetPtr document_set = getDocumentSet (set);
    if( document_set == nullptr ) {
        qCritical("DocumentManager::updateDocuments: invalid document set = '%s'", set.toStdString ().c_str ());
        return false;
    }

    document_set->clear ();

    for( auto &document : documents) {
        QJsonDocument json_doc = QJsonDocument::fromJson(document.toUtf8());
        if (!json_doc.isObject()) {
            qCritical("JSON invalid. '%s'", document.toStdString ().c_str ());
            return false;
        }

        QJsonObject json = json_doc.object();
        QString data = json["data"].toString ();

        Document *d = new Document (data);
        document_set->append (d);
    }

    // TODO: [ian] SUPER hack. Unable to call "emit" on dynamic document set.
    //   it may be possible to use QObject::connect to create a "dispatcher" type object
    //   to emit based on string set name
    //
    if( set == "schematic" ) {
        emit schematicDocumentsChanged();
    }
    else if( set == "assembly" ) {
        emit assemblyDocumentsChanged();
    }
    else if( set == "layout" ) {
        emit layoutDocumentsChanged();
    }
    else if( set == "test_report" ) {
        emit testReportDocumentsChanged();
    }
    else if( set == "targeted_content" ) {
        emit targetedDocumentsChanged();
    }
    else {
        qCritical("DocumentManager::updateDocuments: invalid document set = '%s'", set.toStdString ().c_str ());
    }
    return true;
}
