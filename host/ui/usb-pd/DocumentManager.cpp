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
    qDebug("DocumentManager::DocumentManager() ctor: default");
    init();
}

DocumentManager::DocumentManager(ImplementationInterfaceBinding *implInterfaceBinding) : implInterfaceBinding_(implInterfaceBinding)
{
    qDebug("DocumentManager::DocumentManager() ctor: implInterfaceBinding");
    init();
}

DocumentManager::DocumentManager(QObject *parent) : QObject(parent)
{
    qDebug("DocumentManager::DocumentManager(parent=%p)", parent);
    init();
}

DocumentManager::~DocumentManager ()
{
    document_sets_.clear();
}

void DocumentManager::init()
{
    //qDebug("DocumentManager::init");

    // create document sets: "<name>",  & <name>_documnts_
    document_sets_.emplace(make_pair(QString("schematic"), &schematic_documents_));
    document_sets_.emplace(make_pair(QString("assembly"), &assembly_documents_));
    document_sets_.emplace(make_pair(QString("layout"), &layout_documents_));
    document_sets_.emplace(make_pair(QString("test_report"), &test_report_documents_));
    document_sets_.emplace(make_pair(QString("targeted_content"), &targeted_documents_));

    // register w/ Implementation Interface for Docoument Data Source Updates
    // TODO [ian] change to "document" on cloud update

    struct timespec ts = { 1, 0};
    nanosleep(&ts, NULL);

    implInterfaceBinding_->registerDataSourceHandler("document",
                                                     bind(&DocumentManager::dataSourceHandler,
                                                          this, placeholders::_1));

}

// @f documentDataSourceHandler
// @b handle document data source updates from Implementation Interface
//
// arguments:
//  IN:
//   data : JSON data object
//
//  ERROR:
//    returns true/false
//
//{
//  "cloud_sync": "document_set",
//  "type": "schematic",
//  "documents": [
//    {
//      "data": "*******",
//      "filename": "schematic15.png"
//    }
//  ]
//}
//{
//  "cloud::notification": {
//    "type": "document",
//    "name": "schematic",
//    "documents": [
//      {"data": "*******","filename": "schematic1.png"},
//      {"data": "*******","filename": "schematic1.png"}
//    ]
//  }
//}
//{
//  "cloud::notification": {
//    "type": "marketing",
//    "name": "adas_sensor_fusion",
//    "data": "raw html"
//  }
//}

//
void DocumentManager::dataSourceHandler(QJsonObject data)
{
    qDebug("DocumentManager::documentDataSourceHandler called");

    if (data.contains("name") && data.contains("documents") ) {

        QString name = data.value("name").toString();  // Can be schematic, layout or assembly and so on

        qDebug("DocumentManager::documentDataSourceHandler called : name=%s", name.toStdString().c_str());

        DocumentSetPtr document_set = getDocumentSet (name);
        if( document_set == nullptr ) {
            qCritical("DocumentManager::updateDocuments: invalid document name = '%s'", name.toStdString ().c_str ());
            return;
        }
        document_set->clear ();

        // walk through documents and add to Document Viewer
        QJsonArray document_array = data["documents"].toArray();
        foreach (const QJsonValue &r, document_array) {
            QString fname = r["filename"].toString();
            QString data = r["data"].toString();
            Document *d = new Document (data);
            document_set->append (d);

            //qDebug("fname=%s, data=%.200s", fname.toStdString().c_str(), data.toStdString().c_str());
        }

        // TODO: [ian] SUPER hack. Unable to call "emit" on dynamic document set.
        //   it may be possible to use QObject::connect to create a "dispatcher" type object
        //   to emit based on string set name
        //
        if( name == "schematic" ) {
            emit schematicDocumentsChanged();
        }
        else if( name == "assembly" ) {
            emit assemblyDocumentsChanged();
        }
        else if( name == "layout" ) {
            emit layoutDocumentsChanged();
        }
        else if( name == "test_report" ) {
            emit testReportDocumentsChanged();
        }
        else if( name == "targeted_content" ) {
            emit targetedDocumentsChanged();
        }
        else {
            qCritical("DocumentManager::updateDocuments: invalid document name = '%s'", name.toStdString ().c_str ());
        }
    }
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
    auto document_set = document_sets_.find(set.toStdString ().c_str ());
    if (document_set == document_sets_.end()) {
        qDebug("DocumentManager::getDocumentSet: %s NOT FOUND)", set.toStdString ().c_str ());
        return nullptr;
    }

    return document_set->second;
}
