/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "PlatformDocument.h"
#include "JsonStrings.h"
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
}

QDebug operator<<(QDebug dbg, const PlatformDocument* platfDoc)
{
    const QString classId = (platfDoc) ? platfDoc->classId_ : QChar('-');
    return dbg.nospace().noquote()
        << QStringLiteral("Platform document ") << classId << QStringLiteral(": ");
}

PlatformDocument::PlatformDocument(const QString &classId)
    : classId_(classId)
{
}

bool PlatformDocument::parseDocument(const QByteArray &document)
{
    QJsonParseError parseError;
    const QJsonDocument jsonRoot = QJsonDocument::fromJson(document, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        qCCritical(lcHcsPlatformDocument) << this
            << "Error at offset " << parseError.offset << ": " << parseError.errorString();
        return false;
    }

    const QJsonObject rootObject = jsonRoot.object();

    QJsonObject::const_iterator jsonIter;

    //documents
    jsonIter = rootObject.constFind(JSON_DOCUMENTS);
    if (jsonIter == rootObject.constEnd()) {
        qCCritical(lcHcsPlatformDocument) << this << '\'' << JSON_DOCUMENTS << "' key is missing";
        return false;
    }

    if (jsonIter->isObject() == false) {
        qCCritical(lcHcsPlatformDocument) << this << "value of '" << JSON_DOCUMENTS << "' key is not an object";
        return false;
    }

    const QJsonObject jsonDocument = jsonIter->toObject();

    getArrayResult result;
    QJsonArray jsonArray;

    //datasheets
    result = getArrayFromDocument(jsonDocument, JSON_DATASHEETS, jsonArray);
    if (result == getArrayResult::Ok) {
        populateDatasheetList(jsonArray, datasheetsList_);
    } else {
        // some older platforms do not have 'datasheets' key and rely on datasheets.csv file instead
        if (result != getArrayResult::MissingKey) {
            return false;
        }
    }

    //downloads
    result = getArrayFromDocument(jsonDocument, JSON_DOWNLOADS, jsonArray);
    if (result == getArrayResult::Ok) {
        populateFileList(jsonArray, downloadList_);
    } else {
        return false;
    }

    //views
    result = getArrayFromDocument(jsonDocument, JSON_VIEWS, jsonArray);
    if (result == getArrayResult::Ok) {
        populateFileList(jsonArray, viewList_);
    } else {
        return false;
    }

    //platform selector
    jsonIter = rootObject.constFind(JSON_PLATFORM_SELECTOR);
    if (jsonIter == rootObject.constEnd()) {
        qCCritical(lcHcsPlatformDocument) << this << '\'' << JSON_PLATFORM_SELECTOR << "' key is missing";
        return false;
    }

    if (jsonIter->isObject() == false) {
        qCCritical(lcHcsPlatformDocument) << this << "value of '" << JSON_PLATFORM_SELECTOR << "' key is not an object";
        return false;
    }

    if (populateFileObject(jsonIter->toObject(), platformSelector_) == false) {
        qCCritical(lcHcsPlatformDocument) << this << "value of '" << JSON_PLATFORM_SELECTOR << "' key is not valid";
        return false;
    }

    //name
    name_ = rootObject.value(JSON_NAME).toString();

    //firmware
    result = getArrayFromDocument(rootObject, JSON_FIRMWARE, jsonArray);
    if (result == getArrayResult::Ok) {
        populateFirmwareList(jsonArray, firmwareList_);
    } else {
        // Nowadays, server does not support firmware object. Return false when it will be supported.
        if (result != getArrayResult::MissingKey) {
            return false;
        }
    }

    //control view
    result = getArrayFromDocument(rootObject, JSON_CONTROL_VIEW, jsonArray);
    if (result == getArrayResult::Ok) {
        populateControlViewList(jsonArray, controlViewList_);
    } else {
        // Nowadays, server does not support control_view object. Return false when it will be supported.
        if (result != getArrayResult::MissingKey) {
            return false;
        }
    }

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

const QList<FirmwareFileItem>& PlatformDocument::getFirmwareList()
{
    return firmwareList_;
}

const QList<ControlViewFileItem>& PlatformDocument::getControlViewList()
{
    return controlViewList_;
}

const PlatformFileItem &PlatformDocument::platformSelector()
{
    return platformSelector_;
}

PlatformDocument::getArrayResult PlatformDocument::getArrayFromDocument
    (const QJsonObject &document, const QString &key, QJsonArray &array) const
{
    QJsonObject::const_iterator jsonIter = document.constFind(key);

    if (jsonIter == document.constEnd()) {
        qCWarning(lcHcsPlatformDocument) << this << '\'' << key << "' key is missing";
        return getArrayResult::MissingKey;
    }

    if (jsonIter->isArray()) {
        array = jsonIter->toArray();
        return getArrayResult::Ok;
    }

    qCCritical(lcHcsPlatformDocument) << this << "value of '" << key << "' key is not an array";
    return getArrayResult::NotAnArray;
}

bool PlatformDocument::populateFileObject(const QJsonObject &jsonObject, PlatformFileItem &file)
{
    if (jsonObject.contains(JSON_FILE) == false
            || jsonObject.contains(JSON_MD5) == false
            || jsonObject.contains(JSON_NAME) == false
            || jsonObject.contains(JSON_TIMESTAMP) == false
            || jsonObject.contains(JSON_FILESIZE) == false
            || jsonObject.contains(JSON_PRETTYNAME) == false)
    {
        return false;
    }

    file.partialUri = jsonObject.value(JSON_FILE).toString();
    file.md5 = jsonObject.value(JSON_MD5).toString();
    file.name = jsonObject.value(JSON_NAME).toString();
    file.timestamp = jsonObject.value(JSON_TIMESTAMP).toString();
    file.filesize = jsonObject.value(JSON_FILESIZE).toVariant().toLongLong();
    file.prettyName = jsonObject.value(JSON_PRETTYNAME).toString();

    return true;
}

bool PlatformDocument::populateFirmwareObject(const QJsonObject &jsonObject, FirmwareFileItem &firmwareFile)
{
    uint flags = 0x00;
    bool success = false;

    // clang-format off
    if (jsonObject.contains(JSON_FILE))                 { flags |= 0x01; }  // 00001
    if (jsonObject.contains(JSON_CONTROLLER_CLASS_ID))  { flags |= 0x02; }  // 00010
    if (jsonObject.contains(JSON_MD5))                  { flags |= 0x04; }  // 00100
    if (jsonObject.contains(JSON_TIMESTAMP))            { flags |= 0x08; }  // 01000
    if (jsonObject.contains(JSON_VERSION))              { flags |= 0x10; }  // 10000
    // clang-format on

    switch (flags) {
    case 0x1F :
        firmwareFile.controllerClassId = jsonObject.value(JSON_CONTROLLER_CLASS_ID).toString();
        //fallthrough
    case 0x1D :
        firmwareFile.partialUri = jsonObject.value(JSON_FILE).toString();
        firmwareFile.md5 = jsonObject.value(JSON_MD5).toString();
        firmwareFile.timestamp = jsonObject.value(JSON_TIMESTAMP).toString();
        firmwareFile.version = jsonObject.value(JSON_VERSION).toString();
        success = true;
        break;
    default :
        success = false;
        break;
    }

    return success;
}

bool PlatformDocument::populateControlViewObject(const QJsonObject &jsonObject, ControlViewFileItem &controlViewFile)
{
    if (jsonObject.contains(JSON_FILE) == false
            || jsonObject.contains(JSON_MD5) == false
            || jsonObject.contains(JSON_NAME) == false
            || jsonObject.contains(JSON_TIMESTAMP) == false
            || jsonObject.contains(JSON_VERSION) == false)
    {
        return false;
    }

    controlViewFile.partialUri = jsonObject.value(JSON_FILE).toString();
    controlViewFile.md5 = jsonObject.value(JSON_MD5).toString();
    controlViewFile.name = jsonObject.value(JSON_NAME).toString();
    controlViewFile.timestamp = jsonObject.value(JSON_TIMESTAMP).toString();
    controlViewFile.version = jsonObject.value(JSON_VERSION).toString();

    return true;
}

void PlatformDocument::populateFileList(const QJsonArray &jsonList, QList<PlatformFileItem> &fileList)
{
    foreach (const QJsonValue &value, jsonList) {
        PlatformFileItem fileItem;
        if (populateFileObject(value.toObject() , fileItem) == false) {
            qCCritical(lcHcsPlatformDocument) << this << "file object not valid";
            continue;
        }

        fileList.append(fileItem);
    }
}

void PlatformDocument::populateFirmwareList(const QJsonArray &jsonList, QList<FirmwareFileItem> &firmwareList)
{
    foreach (const QJsonValue &value, jsonList) {
        FirmwareFileItem firmwareItem;
        if (populateFirmwareObject(value.toObject() , firmwareItem) == false) {
            qCCritical(lcHcsPlatformDocument) << this << "firmware object not valid";
            continue;
        }

        firmwareList.append(firmwareItem);
    }
}

void PlatformDocument::populateControlViewList(const QJsonArray &jsonList, QList<ControlViewFileItem> &controlViewList)
{
    foreach (const QJsonValue &value, jsonList) {
        ControlViewFileItem controlViewItem;
        if (populateControlViewObject(value.toObject() , controlViewItem) == false) {
            qCCritical(lcHcsPlatformDocument) << this << "control view object not valid";
            continue;
        }

        controlViewList.append(controlViewItem);
    }
}

bool PlatformDocument::populateDatasheetObject(const QJsonObject &jsonObject, PlatformDatasheetItem &datasheet) {
    if (jsonObject.contains(JSON_CATEGORY) == false
            || jsonObject.contains(JSON_DATASHEET) == false
            || jsonObject.contains(JSON_NAME) == false
            || jsonObject.contains(JSON_OPN) == false
            || jsonObject.contains(JSON_SUBCATEGORY) == false)
    {
        return false;
    }

    datasheet.category = jsonObject.value(JSON_CATEGORY).toString();
    datasheet.datasheet = jsonObject.value(JSON_DATASHEET).toString();
    datasheet.name = jsonObject.value(JSON_NAME).toString();
    datasheet.opn = jsonObject.value(JSON_OPN).toString();
    datasheet.subcategory = jsonObject.value(JSON_SUBCATEGORY).toString();

    return true;
}

void PlatformDocument::populateDatasheetList(const QJsonArray &jsonList, QList<PlatformDatasheetItem> &datasheetList) {
    foreach (const QJsonValue &value, jsonList) {
        PlatformDatasheetItem datasheet;
        if (populateDatasheetObject(value.toObject(), datasheet) == false) {
            qCCritical(lcHcsPlatformDocument) << this << "datasheet object not valid";
            continue;
        }

        datasheetList.append(datasheet);
    }
}
