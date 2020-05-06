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
    coreInterface->registerDataSourceHandler("document_progress",
                                            std::bind(&DocumentManager::documentProgressHandler,
                                            this, std::placeholders::_1));

    coreInterface->registerDataSourceHandler("document",
                                            std::bind(&DocumentManager::loadDocumentHandler,
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

QString DocumentManager::errorString() const
{
    return errorString_;
}

bool DocumentManager::loading() const
{
    return loading_;
}

int DocumentManager::loadingProgressPercentage() const
{
    return loadingProgressPercentage_;
}

void DocumentManager::loadPlatformDocuments(const QString &classId)
{
    setLoadingProgressPercentage(0);
    setLoading(true);
    setErrorString("");
    coreInterface_->connectToPlatform(classId);
}

void DocumentManager::documentProgressHandler(QJsonObject data)
{
    emit updateProgressRequested(data);
}

void DocumentManager::loadDocumentHandler(QJsonObject data)
{
    emit populateModelsRequested(data);
}

void DocumentManager::updateLoadingProgress(QJsonObject data)
{
    QJsonDocument doc(data);
    int filesCompleted = data["files_completed"].toInt();
    int filesTotal = data["files_total"].toInt();

    int progress = filesCompleted / (float)filesTotal * 100;

    setLoadingProgressPercentage(progress);
}

void DocumentManager::populateModels(QJsonObject data)
{
    qCDebug(logCategoryDocumentManager) << "data" << data;

    QList<DocumentItem* > pdfList;
    QList<DocumentItem* > datasheetList;
    QList<DownloadDocumentItem* > downloadList;

    if (data.contains("error")) {
        qCWarning(logCategoryDocumentManager) << "Document download error:" << data["error"].toString();
        clearDocuments();
        setErrorString(data["error"].toString());
        setLoading(false);
        return;
    }

    QJsonArray documentArray = data["documents"].toArray();
    for (const QJsonValue &documentValue : documentArray) {
        QJsonObject documentObject = documentValue.toObject();

        if (documentObject.contains("category") == false
                || documentObject.contains("name")  == false
                || documentObject.contains("prettyname") == false
                || documentObject.contains("uri")  == false) {

            qCWarning(logCategoryDocumentManager) << "file object is not complete";
            continue;
        }

        QString category = documentObject["category"].toString();
        QString uri = documentObject["uri"].toString();
        QString prettyName = documentObject["prettyname"].toString();
        QString name = documentObject["name"].toString();

        if (category == "view") {
            if (name == "datasheet") {
                //for datasheets, parse csv file
                populateDatasheetList(uri, datasheetList);
            } else {
                DocumentItem *di = new DocumentItem(uri, prettyName, name);
                pdfList.append(di);
            }
        } else if (category == "download") {
            if (documentObject.contains("filesize") == false) {
                qCWarning(logCategoryDocumentManager) << "file object is not complete";
                continue;
            }

            qint64 filesize = documentObject["filesize"].toVariant().toLongLong();
            DownloadDocumentItem *ddi = new DownloadDocumentItem(uri, prettyName, name, filesize);
            downloadList.append(ddi);
        } else {
            qCWarning(logCategoryDocumentManager) << "unknown category" << category;
        }
    }

    pdfModel_.populateModel(pdfList);
    datasheetModel_.populateModel(datasheetList);
    downloadDocumentModel_.populateModel(downloadList);

    setLoading(false);
}

void DocumentManager::clearDocuments()
{
    pdfModel_.clear();
    datasheetModel_.clear();
    downloadDocumentModel_.clear();
    setErrorString("");
}

void DocumentManager::setErrorString(QString errorString) {
    if (errorString_ != errorString) {
        errorString_ = errorString;
        emit errorStringChanged();
    }
}

void DocumentManager::setLoading(bool loading)
{
    if (loading_ != loading) {
        loading_ = loading;
        emit loadingChanged();
    }
}

void DocumentManager::setLoadingProgressPercentage(int loadingProgress)
{
    if (loadingProgressPercentage_ != loadingProgress) {
        loadingProgressPercentage_ = loadingProgress;
        emit loadingProgressPercentageChanged();
    }
}

void DocumentManager::init()
{
    /* Due to std::bind(), DocumentManager::viewDocumentHandler() runs in a thread of CoreInterface,
     * which is different from GUI thread.
     * Data manipulation affecting GUI must run in the same thread as GUI.
     * This connection allow us to move data manipulation to the main (GUI) thread.
     */
    connect(this, &DocumentManager::populateModelsRequested, this, &DocumentManager::populateModels);
    connect(this, &DocumentManager::updateProgressRequested, this, &DocumentManager::updateLoadingProgress);
}

void DocumentManager::populateDatasheetList(const QString &path, QList<DocumentItem *> &list)
{
    list.clear();

    QFile file(path);
    if (file.open(QIODevice::ReadOnly) == false) {
        qCWarning(logCategoryDocumentManager) << file.errorString();
        return;
    }

    while (file.atEnd() == false) {
        QString line = file.readLine();
        line.remove(QRegExp("\n|\r\n|\r"));

        // Split on commas that are not inside quotes
        QStringList datasheetLine = line.split(QRegExp("(,)(?=(?:[^\"]|\"[^\"]*\")*$)"));

        // Remove quotes that stem from commas in CSV titles
        datasheetLine.replaceInStrings("\"", "");

        // 3rd cell in row matches "https://***.pdf"
        if (QRegExp("^(http:\\/\\/|https:\\/\\/).+(\\.(p|P)(d|D)(f|F))$").exactMatch(datasheetLine.at(2))) {

            DocumentItem *di = new DocumentItem(datasheetLine.at(2), datasheetLine.at(0), datasheetLine.at(1));
            list.append(di);
        }
    }

    file.close();
}

