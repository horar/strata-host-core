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

    int progress = filesCompleted / (float)filesTotal * 100;

    setLoadingProgressPercentage(progress);
}

void ClassDocuments::populateModels(QJsonObject data)
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
