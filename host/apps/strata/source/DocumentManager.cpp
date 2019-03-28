//
// author: ian
// date: 25 October 2017
//
// Document Manager class to interact with corresponding QML SGDocumentViewer Widget
//

#include "DocumentManager.h"

#include "logging/LoggingQtCategories.h"

#include <QObject>
#include <QJsonObject>
#include <QJsonArray>
#include <QFileInfo>
#include <QDir>

using namespace std;

DocumentManager::DocumentManager()
{
    qCDebug(logCategoryDocumentManager) << " ctor: default";
    init();
}

DocumentManager::DocumentManager(CoreInterface *coreInterface) : coreInterface_(coreInterface)
{
    qCDebug(logCategoryDocumentManager) << "core interface";
    /*
        Register document handler with CoreInterface
        This will also send a command to Nimbus
    */
    coreInterface->registerDataSourceHandler("document",
                                            bind(&DocumentManager::viewDocumentHandler,
                                            this, placeholders::_1));
    init();
}

DocumentManager::DocumentManager(QObject *parent) : QObject(parent)
{
    qCDebug(logCategoryDocumentManager) << "(parent=" << parent << ")";
    init();
}

DocumentManager::~DocumentManager ()
{
    document_sets_.clear();
}

void DocumentManager::init()
{
    //qCDebug(logCategoryDocumentManager);

    // create document sets: "<name>",  & <name>_documnts_

    document_sets_.emplace(make_pair(QString("pdf"), &pdf_documents_));
    document_sets_.emplace(make_pair(QString("download"), &download_documents_));
    document_sets_.emplace(make_pair(QString("datasheet"), &datasheet_documents_));

    pdf_rev_count_ =  0;
    download_rev_count_ =   0;
    datasheet_rev_count_ =   0;
    // register w/ Implementation Interface for Docoument Data Source Updates
    // TODO [ian] change to "document" on cloud update

    // TODO [ian] hack around some messaging issue we have that dead locks the communications
    //             without the sleep.
    //
    //sleep(2);
    //platformInterface_->registerDataSourceHandler("document",
    //                                                 bind(&DocumentManager::viewDocumentHandler,
    //                                                      this, placeholders::_1));

}

// @f viewDocumentHandler
// @b handle view document source updates from Implementation Interface
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
//      "uri": "x/x/x/xxxx.pdf"
//    }
//  ]
//}
//{
//  "cloud::notification": {
//    "type": "document",
//    "name": "schematic",
//    "documents": [
//      {"uri": "x/x/x/yyyy.pdf"},
//      {"uri": "x/x/x/xxxx.pdf"}
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
void DocumentManager::viewDocumentHandler(QJsonObject data)
{
    qCDebug(logCategoryDocumentManager) << " called";

    if (data.contains("documents") ) {
        QJsonArray document_array = data["documents"].toArray();

        foreach (const QJsonValue &documentValue, document_array) {
            QJsonObject documentObject = documentValue.toObject();

            if (documentObject.contains("name") && documentObject.contains("uri")){
                QString name = documentObject["name"].toString();
                QString uri = documentObject["uri"].toString();

                if (name != "download" && name != "datasheet") {
                    name = QString("pdf");
                }

                DocumentSetPtr document_set = getDocumentSet (name);

                if( document_set == nullptr ) {
                    qCritical(logCategoryDocumentManager) << "invalid document name = '" << name.toStdString().c_str () << "'";
                    return;
                }
                //                    document_set->clear ();

                if (name == "datasheet") {
                    // For datasheet, parse local csv into document list for UI to pick up parts, categories and PDF urls
                    QFile file(uri);
                    if (!file.open(QIODevice::ReadOnly)) {
                        qCDebug(logCategoryDocumentManager) << file.errorString();
                    }

                    // Create a document and add to datasheet_documents_ for each lines of CSV
                    while (!file.atEnd()) {
                        QString line = file.readLine();
                        line.remove(QRegExp("\n|\r\n|\r"));
                        QStringList datasheetLine = line.split(QRegExp("(,)(?=(?:[^\"]|\"[^\"]*\")*$)"));  // Split on commas that are not inside quotes
                        datasheetLine.replaceInStrings("\"", "");  // Remove quotes that stem from commas in CSV titles
                        Document *d = new Document (datasheetLine.at(2), datasheetLine.at(0), datasheetLine.at(1));
                        document_set->append (d);
                    }
                    file.close();

                } else {
                    QFileInfo fi(uri);
                    QString filename = fi.fileName();
                    QDir dir(fi.dir());
                    QString dirname = dir.dirName();
                    if (dirname == "faq") {
                        dirname = "FAQ";
                    }
                    Document *d = new Document (uri, filename, dirname);
                    if (dirname == "layout") {  // Sort layout to front
                        document_set->insert (0, d);
                    } else {
                        document_set->append (d);
                    }
                }


                // TODO: [ian] SUPER hack. Unable to call "emit" on dynamic document set.
                //   it may be possible to use QObject::connect to create a "dispatcher" type object
                //   to emit based on string set name
                //
        //        if( name == "pdf" ) {
        //            emit pdfDocumentsChanged();
        //            emit pdfRevisionCountChanged(++pdfrev_count_);
        //        }
        //        else if( name == "download" ) {
        //            emit downloadDocumentsChanged();
        //            emit downloadRevisionCountChanged(++download_rev_count_);
        //        }
        //        else if( name == "datasheet" ) {
        //            emit datasheetDocumentsChanged();
        //            emit datasheetRevisionCountChanged(++datasheet_rev_count_);
        //        }
        //        else {
        //            qCritical(logCategoryDocumentManager) << "invalid document name = " << '" << name.toStdString ().c_str () << "'";
        //        }
            }
        }

        // Signal that stops doc loading spinner
        emit documentsUpdated();
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
        qCDebug(logCategoryDocumentManager) << set.toStdString ().c_str () << " NOT FOUND";
        return nullptr;
    }

    return document_set->second;
}

void DocumentManager::clearDocumentSets()
{
    for (auto doc_iter = document_sets_.begin(); doc_iter!= document_sets_.end(); doc_iter++)
    {
        doc_iter->second->clear();
    }

}

void DocumentManager::clearPdfRevisionCount() {
    pdf_rev_count_ = 0;
    emit pdfRevisionCountChanged(pdf_rev_count_);
}

void DocumentManager::clearDownloadRevisionCount() {
    download_rev_count_ = 0;
    emit downloadRevisionCountChanged(download_rev_count_);
}

void DocumentManager::clearDatasheetRevisionCount() {
    datasheet_rev_count_ = 0;
    emit datasheetRevisionCountChanged(datasheet_rev_count_);
}
