
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

    //documents
    if (jsonRoot.object().contains("documents") == false) {
        qCCritical(logCategoryHcsPlatformDocument) << "documents key is missing";
        return false;
    }

    QJsonValue documentsValue = jsonRoot.object().value("documents");
    if (documentsValue.isObject() == false) {
        qCCritical(logCategoryHcsPlatformDocument) << "value of documents key is not an object";
        return false;
    }

    QJsonObject jsonDocument = documentsValue.toObject();

    //downloads
    if (jsonDocument.contains("downloads") == false) {
        qCCritical(logCategoryHcsPlatformDocument) << "downloads key is missing";
        return false;
    }

    QJsonValue downloadsValue = jsonDocument.value("downloads");
    if (downloadsValue.isArray()) {
        populateFileList(downloadsValue.toArray(), downloadList_);
    } else {
        qCCritical(logCategoryHcsPlatformDocument) << "value of downloads key is not an array";
        return false;
    }

    //views
    if (jsonDocument.contains("views") == false) {
        qCCritical(logCategoryHcsPlatformDocument) << "views key is missing";
        return false;
    }

    QJsonValue viewsValue = jsonDocument.value("views");
    if (viewsValue.isArray()) {
        populateFileList(viewsValue.toArray(), viewList_);
    } else {
        qCCritical(logCategoryHcsPlatformDocument) << "value of views key is not an array";
        return false;
    }

    //platform selector
    QJsonObject jsonPlatformSelector = jsonRoot.object().value("platform_selector").toObject();
    if (jsonPlatformSelector.isEmpty()) {
        qCCritical(logCategoryHcsPlatformDocument) << "platform_selector key is missing";
        return false;
    }

    bool isValid = populateFileObject(jsonPlatformSelector, platformSelector_);
    if (isValid == false) {
        qCCritical(logCategoryHcsPlatformDocument) << "value of platform_selector key is not valid";
        return false;
    }

    //name
    name_ = jsonRoot.object().value("name").toString();

    //firmware
    if (jsonDocument.contains("firmware") == false) {
        qCCritical(logCategoryHcsPlatformDocument) << "firmware key is missing";
        // TODO: Nowadays, server does not support firmware object. Return false when it will be supported.
        //return false;
    }
    else {  // TODO: Remove this else when server will support firmware object.
        QJsonValue firmwareValue = jsonDocument.value("firmware");
        if (firmwareValue.isArray()) {
            populateFirmwareList(firmwareValue.toArray(), firmwareList_);
        } else {
            qCCritical(logCategoryHcsPlatformDocument) << "value of firmware key is not an array";
            return false;
        }
    }  // TODO: remove this else

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

const QList<PlatformFileItem>& PlatformDocument::getDownloadList()
{
    return downloadList_;
}

const QList<FirmwareItem>& PlatformDocument::getFirmwareList()
{
    return firmwareList_;
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
            || jsonObject.contains("filesize") == false
            || jsonObject.contains("prettyName") == false)
    {
        return false;
    }

    file.partialUri = jsonObject.value("file").toString();
    file.md5 = jsonObject.value("md5").toString();
    file.name = jsonObject.value("name").toString();
    file.timestamp = jsonObject.value("timestamp").toString();
    file.filesize = jsonObject.value("filesize").toVariant().toLongLong();
    file.prettyName = jsonObject.value("prettyName").toString();

    return true;
}

bool PlatformDocument::populateFirmwareObject(const QJsonObject &jsonObject, FirmwareItem &firmware)
{
    if (jsonObject.contains("file") == false
            || jsonObject.contains("md5") == false
            || jsonObject.contains("name") == false
            || jsonObject.contains("timestamp") == false
            || jsonObject.contains("version") == false)
    {
        return false;
    }

    firmware.partialUri = jsonObject.value("file").toString();
    firmware.md5 = jsonObject.value("md5").toString();
    firmware.name = jsonObject.value("name").toString();
    firmware.timestamp = jsonObject.value("timestamp").toString();
    firmware.version = jsonObject.value("version").toString();

    return true;
}

void PlatformDocument::populateFileList(const QJsonArray &jsonList, QList<PlatformFileItem> &fileList)
{
    foreach (const QJsonValue &value, jsonList) {
        PlatformFileItem fileItem;
        if (populateFileObject(value.toObject() , fileItem) == false) {
            qCCritical(logCategoryHcsPlatformDocument) << "file object not valid";
            continue;
        }

        fileList.append(fileItem);
    }
}

void PlatformDocument::populateFirmwareList(const QJsonArray &jsonList, QList<FirmwareItem> &firmwareList)
{
    foreach (const QJsonValue &value, jsonList) {
        FirmwareItem firmwareItem;
        if (populateFirmwareObject(value.toObject() , firmwareItem) == false) {
            qCCritical(logCategoryHcsPlatformDocument) << "firmware object not valid";
            continue;
        }

        firmwareList.append(firmwareItem);
    }
}
