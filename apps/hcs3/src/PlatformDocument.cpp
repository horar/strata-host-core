/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

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
    const QJsonDocument jsonRoot = QJsonDocument::fromJson(document.toUtf8(), &parseError);

    if (parseError.error != QJsonParseError::NoError ) {
        return false;
    }

    const QJsonObject rootObject = jsonRoot.object();

    //documents
    if (rootObject.contains("documents") == false) {
        qCCritical(lcHcsPlatformDocument) << "documents key is missing";
        return false;
    }

    QJsonValue documentsValue = rootObject.value("documents");
    if (documentsValue.isObject() == false) {
        qCCritical(lcHcsPlatformDocument) << "value of documents key is not an object";
        return false;
    }

    QJsonObject jsonDocument = documentsValue.toObject();

    //datasheets
    if (jsonDocument.contains("datasheets") == false) {
        qCWarning(lcHcsPlatformDocument) << "datasheets key is missing";
        // skip - some older platforms rely on datasheets.csv file instead
    } else {
        QJsonValue datasheetsValue = jsonDocument.value("datasheets");
        if (datasheetsValue.isArray()) {
            populateDatasheetList(datasheetsValue.toArray(), datasheetsList_);
        } else {
            qCCritical(lcHcsPlatformDocument) << "value of datasheets key is not an array";
            return false;
        }
    }

    //downloads
    if (jsonDocument.contains("downloads") == false) {
        qCCritical(lcHcsPlatformDocument) << "downloads key is missing";
        return false;
    }

    QJsonValue downloadsValue = jsonDocument.value("downloads");
    if (downloadsValue.isArray()) {
        populateFileList(downloadsValue.toArray(), downloadList_);
    } else {
        qCCritical(lcHcsPlatformDocument) << "value of downloads key is not an array";
        return false;
    }

    //views
    if (jsonDocument.contains("views") == false) {
        qCCritical(lcHcsPlatformDocument) << "views key is missing";
        return false;
    }

    QJsonValue viewsValue = jsonDocument.value("views");
    if (viewsValue.isArray()) {
        populateFileList(viewsValue.toArray(), viewList_);
    } else {
        qCCritical(lcHcsPlatformDocument) << "value of views key is not an array";
        return false;
    }

    //platform selector
    QJsonObject jsonPlatformSelector = rootObject.value("platform_selector").toObject();
    if (jsonPlatformSelector.isEmpty()) {
        qCCritical(lcHcsPlatformDocument) << "platform_selector key is missing";
        return false;
    }

    bool isValid = populateFileObject(jsonPlatformSelector, platformSelector_);
    if (isValid == false) {
        qCCritical(lcHcsPlatformDocument) << "value of platform_selector key is not valid";
        return false;
    }

    //name
    name_ = rootObject.value("name").toString();

    //firmware
    if (rootObject.contains("firmware") == false) {
        qCCritical(lcHcsPlatformDocument) << "firmware key is missing";
        // TODO: Nowadays, server does not support firmware object. Return false when it will be supported.
        //return false;
    }
    else {  // TODO: Remove this else line when server will support firmware object.
        QJsonValue firmwareValue = rootObject.value("firmware");
        if (firmwareValue.isArray()) {
            populateVersionedList(firmwareValue.toArray(), firmwareList_);
        } else {
            qCCritical(lcHcsPlatformDocument) << "value of firmware key is not an array";
            return false;
        }
    }  // TODO: remove this else line

    //control view
    if (rootObject.contains("control_view") == false) {
        qCCritical(lcHcsPlatformDocument) << "control_view key is missing";
        // TODO: Nowadays, server does not support control_view object. Return false when it will be supported.
        //return false;
    }
    else {  // TODO: Remove this else line when server will support control_view object.
        QJsonValue controlViewValue = rootObject.value("control_view");
        if (controlViewValue.isArray()) {
            populateVersionedList(controlViewValue.toArray(), controlViewList_);
        } else {
            qCCritical(lcHcsPlatformDocument) << "value of control_view key is not an array";
            return false;
        }
    }  // TODO: remove this else line

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

const QList<PlatformDatasheetItem>& PlatformDocument::getDatasheetList()
{
    return datasheetsList_;
}

const QList<PlatformFileItem>& PlatformDocument::getDownloadList()
{
    return downloadList_;
}

const QList<VersionedFileItem>& PlatformDocument::getFirmwareList()
{
    return firmwareList_;
}

const QList<VersionedFileItem>& PlatformDocument::getControlViewList()
{
    return controlViewList_;
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

bool PlatformDocument::populateVersionedObject(const QJsonObject &jsonObject, VersionedFileItem &versionedFile)
{
    if (jsonObject.contains("file") == false
            || jsonObject.contains("md5") == false
            || jsonObject.contains("name") == false
            || jsonObject.contains("timestamp") == false
            || jsonObject.contains("version") == false)
    {
        return false;
    }

    versionedFile.partialUri = jsonObject.value("file").toString();
    versionedFile.md5 = jsonObject.value("md5").toString();
    versionedFile.name = jsonObject.value("name").toString();
    versionedFile.timestamp = jsonObject.value("timestamp").toString();
    versionedFile.version = jsonObject.value("version").toString();

    return true;
}

void PlatformDocument::populateFileList(const QJsonArray &jsonList, QList<PlatformFileItem> &fileList)
{
    foreach (const QJsonValue &value, jsonList) {
        PlatformFileItem fileItem;
        if (populateFileObject(value.toObject() , fileItem) == false) {
            qCCritical(lcHcsPlatformDocument) << "file object not valid";
            continue;
        }

        fileList.append(fileItem);
    }
}

void PlatformDocument::populateVersionedList(const QJsonArray &jsonList, QList<VersionedFileItem> &versionedList)
{
    foreach (const QJsonValue &value, jsonList) {
        VersionedFileItem firmwareItem;
        if (populateVersionedObject(value.toObject() , firmwareItem) == false) {
            qCCritical(lcHcsPlatformDocument) << "versioned file object not valid";
            continue;
        }

        versionedList.append(firmwareItem);
    }
}

bool PlatformDocument::populateDatasheetObject(const QJsonObject &jsonObject, PlatformDatasheetItem &datasheet) {
    if (jsonObject.contains("category") == false
            || jsonObject.contains("datasheet") == false
            || jsonObject.contains("name") == false
            || jsonObject.contains("opn") == false
            || jsonObject.contains("subcategory") == false)
    {
        return false;
    }

    datasheet.category = jsonObject.value("category").toString();
    datasheet.datasheet = jsonObject.value("datasheet").toString();
    datasheet.name = jsonObject.value("name").toString();
    datasheet.opn = jsonObject.value("opn").toString();
    datasheet.subcategory = jsonObject.value("subcategory").toString();

    return true;
}

void PlatformDocument::populateDatasheetList(const QJsonArray &jsonList, QList<PlatformDatasheetItem> &datasheetList) {
    foreach (const QJsonValue &value, jsonList) {
        PlatformDatasheetItem datasheet;
        if (populateDatasheetObject(value.toObject(), datasheet) == false) {
            qCCritical(lcHcsPlatformDocument) << "datasheet object not valid";
            continue;
        }

        datasheetList.append(datasheet);
    }
}
