
#include "PlatformDocument.h"
#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>

QDebug operator<<(QDebug dbg, const PlatformFileItem &item) {

    dbg.nospace() << "PlatformFileItem("
                  << "name=" << item.name
                  << ", partialUri="<< item.partialUri
                  << ", timestamp=" << item.timestamp
                  << ", md5=" << item.md5
                  << ")";

    return dbg.maybeSpace();
};

PlatformDocument::PlatformDocument(const QString &classId)
    : classId_(classId)
{
}

bool PlatformDocument::parseDocument(const QString &document)
{
    QJsonParseError parseError;
    QJsonDocument jsonRoot = QJsonDocument::fromJson(document.toUtf8(), &parseError);

    if (parseError.error != QJsonParseError::NoError ) {
        return false;
    }

    QJsonObject jsonDocument = jsonRoot.object().value("documents").toObject();
    if (jsonDocument.isEmpty()) {
        qCWarning(logCategoryHcsPlatformDocument) << "documents object does not exist in the platform document";
        return false;
    }

    //downloads
    QJsonArray jsonDownloadList = jsonDocument.value("downloads").toArray();
    if (jsonDownloadList.isEmpty()) {
        qCWarning(logCategoryHcsPlatformDocument) << "downloads object is missing";
        return false;
    }

    populateFileList(jsonDownloadList, downloadList_);

    //views
    QJsonArray jsonViewList = jsonDocument.value("views").toArray();
    if (jsonViewList.isEmpty()) {
        qCWarning(logCategoryHcsPlatformDocument) << "views object is missing";
        return false;
    }

    populateFileList(jsonViewList, viewList_);

    //platform selector
    QJsonObject jsonPlatformSelector = jsonRoot.object().value("platform_selector").toObject();
    if (jsonPlatformSelector.isEmpty()) {
        qCWarning(logCategoryHcsPlatformDocument) << "platform_selector object does not exist in the platform document";
        return false;
    }

    bool isValid = populateFileObject(jsonPlatformSelector, platformSelector_);
    if (isValid == false) {
        qCWarning(logCategoryHcsPlatformDocument) << "platform_selector object is not valid";
        return false;
    }

    //name
    name_ = jsonRoot.object().value("name").toString();

    return true;
}

QString PlatformDocument::classId()
{
    return classId_;
}

const QList<PlatformFileItem>& PlatformDocument::getViewList()
{
    return viewList_;
}

const QList<PlatformFileItem> &PlatformDocument::getDownloadList()
{
    return downloadList_;
}

const PlatformFileItem &PlatformDocument::platformSelector()
{
    return platformSelector_;
}

bool PlatformDocument::populateFileObject(const QJsonObject &jsonObject, PlatformFileItem &file)
{
    if (jsonObject.contains("file") == false
            || jsonObject.contains("md5") == false
            || jsonObject.contains("name") == false
            || jsonObject.contains("timestamp") == false
            || jsonObject.contains("filesize") == false)
    {
        return false;
    }

    file.partialUri = jsonObject.value("file").toString();
    file.md5 = jsonObject.value("md5").toString();
    file.name = jsonObject.value("name").toString();
    file.timestamp = jsonObject.value("timestamp").toString();
    file.filesize = jsonObject.value("filesize").toVariant().toLongLong();

    return true;
}

void PlatformDocument::populateFileList(const QJsonArray &jsonList, QList<PlatformFileItem> &fileList)
{
    foreach (const QJsonValue &value, jsonList) {
        PlatformFileItem fileItem;
        if (populateFileObject(value.toObject() , fileItem) == false) {
            qCWarning(logCategoryHcsPlatformDocument) << "object not valid";
            continue;
        }

        fileList.append(fileItem);
    }
}
