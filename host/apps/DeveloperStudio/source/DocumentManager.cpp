#include "DocumentManager.h"

#include "logging/LoggingQtCategories.h"

#include <QObject>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFileInfo>
#include <QDir>
#include <QList>

DocumentManager::DocumentManager(CoreInterface *coreInterface, QObject *parent)
    : coreInterface_(coreInterface),
      downloadDocumentModel_(coreInterface, parent)

{
    qCDebug(logCategoryDocumentManager) << "core interface";
    /*
        Register document handler with CoreInterface
        This will also send a command to Nimbus
    */
    coreInterface->registerDataSourceHandler("document",
                                            std::bind(&DocumentManager::viewDocumentHandler,
                                            this, std::placeholders::_1));
    init();
}

DocumentManager::~DocumentManager ()
{
}

DownloadDocumentListModel *DocumentManager::downloadDocumentListModel()
{
    return &downloadDocumentModel_;
}

DocumentListModel *DocumentManager::datasheetListModel()
{
    return &datasheetModel_;
}

DocumentListModel *DocumentManager::pdfListModel()
{
    return &pdfModel_;
}

QString DocumentManager::errorState()
{
    return errorState_;
}

void DocumentManager::init()
{
    /* Due to std::bind(), DocumentManager::viewDocumentHandler() runs in a thread of CoreInterface,
     * which is different from GUI thread.
     * Data manipulation affecting GUI must run in the same thread as GUI.
     * This connection allow us to move data manipulation to the main (GUI) thread.
     */
    connect(this, &DocumentManager::populateModelsReguest, this, &DocumentManager::populateModels);

    pdf_rev_count_ =  0;
    download_rev_count_ = 0;
    datasheet_rev_count_ = 0;
}

void DocumentManager::viewDocumentHandler(QJsonObject data)
{
    emit populateModelsReguest(data);
}

void DocumentManager::populateModels(QJsonObject data)
{
    qCDebug(logCategoryDocumentManager) << "data" << data;

    QList<DocumentItem* > pdfList;
    QList<DocumentItem* > datasheetList;
    QList<DownloadDocumentItem* > downloadList;

    if (data.contains("documents") ) {
        setErrorState("");

        QJsonArray document_array = data["documents"].toArray();

        foreach (const QJsonValue &documentValue, document_array) {
            QJsonObject documentObject = documentValue.toObject();

            if (documentObject.contains("name") && documentObject.contains("uri") && documentObject.contains("filesize")){
                QString name = documentObject["name"].toString();
                QString uri = documentObject["uri"].toString();
                qint64 filesize = documentObject["filesize"].toVariant().toLongLong();

                if (name != "download" && name != "datasheet") {
                    name = QString("pdf");
                }

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

                        if (QRegExp("^(http:\\/\\/|https:\\/\\/).+(\\.(p|P)(d|D)(f|F))$").exactMatch(datasheetLine.at(2))) { // 3rd cell in row matches "https://***.pdf"

                            DocumentItem *di = new DocumentItem(datasheetLine.at(2), datasheetLine.at(0), datasheetLine.at(1));
                            datasheetList.append(di);
                        }
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

                    if (name == "download") {
                        DownloadDocumentItem *ddi = new DownloadDocumentItem(uri, filename, dirname, filesize);
                        downloadList.append(ddi);
                    } else {
                        DocumentItem *di = new DocumentItem(uri, filename, dirname);

                        // Sort layout to front
                        if (dirname == "layout") {
                            pdfList.prepend(di);
                        } else {
                            pdfList.append(di);
                        }
                    }
                }
            }
        }

        pdfModel_.populateModel(pdfList);
        datasheetModel_.populateModel(datasheetList);
        downloadDocumentModel_.populateModel(downloadList);

    } else if (data.contains("error")) {
        qCWarning(logCategoryDocumentManager) << "Document download error:" << data["error"].toString();
        setErrorState(data["error"].toString());
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

void DocumentManager::clearDocuments()
{
    pdfModel_.clear();
    datasheetModel_.clear();
    downloadDocumentModel_.clear();
}

void DocumentManager::setErrorState(QString errorState) {
    if (errorState_ != errorState) {
        errorState_ = errorState;
        emit errorStateChanged();
    }
}
