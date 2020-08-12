#include "ClassDocuments.h"

#include "logging/LoggingQtCategories.h"

#include <QObject>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFileInfo>
#include <QDir>
#include <QList>

ClassDocuments::ClassDocuments(QString classId, CoreInterface *coreInterface, QObject *parent)
    : QObject(parent),
      classId_(classId),
      coreInterface_(coreInterface),
      downloadDocumentModel_(coreInterface, parent)
{
    loadPlatformDocuments();
}

DownloadDocumentListModel *ClassDocuments::downloadDocumentListModel()
{
    return &downloadDocumentModel_;
}

DocumentListModel *ClassDocuments::datasheetListModel()
{
    return &datasheetModel_;
}

DocumentListModel *ClassDocuments::pdfListModel()
{
    return &pdfModel_;
}

VersionedListModel *ClassDocuments::firmwareListModel()
{
    return &firmwareModel_;
}

VersionedListModel *ClassDocuments::controlViewListModel()
{
    return &controlViewModel_;
}

QString ClassDocuments::errorString() const
{
    return errorString_;
}

bool ClassDocuments::loading() const
{
    return loading_;
}

int ClassDocuments::loadingProgressPercentage() const
{
    return loadingProgressPercentage_;
}

void ClassDocuments::loadPlatformDocuments()
{
    setLoadingProgressPercentage(0);
    setLoading(true);
    setErrorString("");
    coreInterface_->connectToPlatform(classId_);
}

void ClassDocuments::updateLoadingProgress(QJsonObject data)
{
    QJsonDocument doc(data);
    int filesCompleted = data["files_completed"].toInt();
    int filesTotal = data["files_total"].toInt();

    int progress = 100 * filesCompleted / filesTotal;

    setLoadingProgressPercentage(progress);
}

void ClassDocuments::populateModels(QJsonObject data)
{
    qCDebug(logCategoryDocumentManager) << "data" << data;

    QList<DocumentItem* > pdfList;
    QList<DocumentItem* > datasheetList;
    QList<DownloadDocumentItem* > downloadList;
    QList<VersionedItem* > firmwareList;
    QList<VersionedItem* > controlViewList;

    if (data.contains("error")) {
        qCWarning(logCategoryDocumentManager) << "Document download error:" << data["error"].toString();
        clearDocuments();
        setErrorString(data["error"].toString());
        setLoading(false);
        return;
    }

    // Populate datasheetList if the supplied jsonObject contains any datasheet information in the datasheets property
    bool parseDatasheetCSV = true;
    QJsonArray datasheetArray = data["datasheets"].toArray();
    for (const QJsonValueRef value : datasheetArray) {
        QJsonObject datasheetObject = value.toObject();

        if (datasheetObject.contains("category") == false
                || datasheetObject.contains("datasheet") == false
                || datasheetObject.contains("name") == false
                || datasheetObject.contains("opn") == false
                || datasheetObject.contains("subcategory") == false)
        {
            qCWarning(logCategoryDocumentManager) << "datasheet object is not complete";
            continue;
        }

        QString category = datasheetObject.value("category").toString();
        QString uri = datasheetObject.value("datasheet").toString();
        QString name = datasheetObject.value("name").toString();

        DocumentItem *di = new DocumentItem(uri, name, category);
        datasheetList.append(di);

        // We have encountered at least one datasheet in the "datasheets" list, so we don't need to parse the datasheet csv file
        parseDatasheetCSV = false;
    }

    QJsonArray documentArray = data["documents"].toArray();
    for (const QJsonValueRef documentValue : documentArray) {
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
                if (parseDatasheetCSV) {
                    //for datasheets, parse csv file
                    qCDebug(logCategoryDocumentManager) << "parsing datasheet csv file";
                    populateDatasheetList(uri, datasheetList);
                }
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

    QJsonArray firmwareArray = data["firmwares"].toArray();
    for (const QJsonValueRef firmwareValue : firmwareArray) {
        QJsonObject documentObject = firmwareValue.toObject();

        if (documentObject.contains("uri") == false
                || documentObject.contains("md5")  == false
                || documentObject.contains("name") == false
                || documentObject.contains("timestamp")  == false
                || documentObject.contains("version")  == false) {

            qCWarning(logCategoryDocumentManager) << "firmware object is not complete";
            continue;
        }

        QJsonDocument doc(documentObject);
        QString strJson(doc.toJson(QJsonDocument::Compact));

        QString uri = documentObject["uri"].toString();
        QString name = documentObject["name"].toString();
        QString md5 = documentObject["md5"].toString();
        QString version = documentObject["version"].toString();
        QString timestamp = documentObject["timestamp"].toString();

        VersionedItem *firmwareItem = new VersionedItem(uri, md5, name, timestamp, version);
        firmwareList.append(firmwareItem);
    }

    QJsonArray controlViewArray = data["control_views"].toArray();
    for (const QJsonValueRef controlViewValue : controlViewArray) {
        QJsonObject documentObject = controlViewValue.toObject();

        if (documentObject.contains("uri") == false
                || documentObject.contains("md5")  == false
                || documentObject.contains("name") == false
                || documentObject.contains("timestamp")  == false
                || documentObject.contains("version")  == false
                || documentObject.contains("filepath") == false) {

            qCWarning(logCategoryDocumentManager) << "control view object is not complete";
            continue;
        }

        QJsonDocument doc(documentObject);
        QString strJson(doc.toJson(QJsonDocument::Compact));

        QString uri = documentObject["uri"].toString();
        QString name = documentObject["name"].toString();
        QString md5 = documentObject["md5"].toString();
        QString version = documentObject["version"].toString();
        QString timestamp = documentObject["timestamp"].toString();
        QString filepath = documentObject["filepath"].toString();

        VersionedItem *controlViewItem = new VersionedItem(uri, md5, name, timestamp, version, filepath);
        controlViewList.append(controlViewItem);
    }

    pdfModel_.populateModel(pdfList);
    datasheetModel_.populateModel(datasheetList);
    downloadDocumentModel_.populateModel(downloadList);
    firmwareModel_.populateModel(firmwareList);
    controlViewModel_.populateModel(controlViewList);

    setLoading(false);
}

void ClassDocuments::clearDocuments()
{
    pdfModel_.clear();
    datasheetModel_.clear();
    downloadDocumentModel_.clear();
    setErrorString("");
}

void ClassDocuments::setErrorString(QString errorString) {
    if (errorString_ != errorString) {
        errorString_ = errorString;
        emit errorStringChanged();
    }
}

void ClassDocuments::setLoading(bool loading)
{
    if (loading_ != loading) {
        loading_ = loading;
        emit loadingChanged();
    }
}

void ClassDocuments::setLoadingProgressPercentage(int loadingProgress)
{
    if (loadingProgressPercentage_ != loadingProgress) {
        loadingProgressPercentage_ = loadingProgress;
        emit loadingProgressPercentageChanged();
    }
}

void ClassDocuments::populateDatasheetList(const QString &path, QList<DocumentItem *> &list)
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
