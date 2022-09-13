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

constexpr int CONTROLLER_TYPE_NOT_APPLICABLE(0);
constexpr int CONTROLLER_TYPE_EMBEDDED(1);
constexpr int CONTROLLER_TYPE_ASSISTED(2);
constexpr int CONTROLLER_TYPE_CONTROLLER(3);

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

    int controllerType;
    {
        const QJsonValue controllerValue = rootObject.value(JSON_CONTROLLER_TYPE);
        if (controllerValue.isDouble() == false) {
            qCCritical(lcHcsPlatformDocument) << this << "key '" << JSON_CONTROLLER_TYPE << "' is not a number / is missing";
            return false;
        }
        controllerType = controllerValue.toInt(-1);
        if (controllerType != CONTROLLER_TYPE_EMBEDDED
                && controllerType != CONTROLLER_TYPE_ASSISTED
                && controllerType != CONTROLLER_TYPE_CONTROLLER
                && controllerType != CONTROLLER_TYPE_NOT_APPLICABLE) {
            qCCritical(lcHcsPlatformDocument) << this << "unsupported value ("
                << controllerValue.toDouble() << ") of '" << JSON_CONTROLLER_TYPE << "' key";
            return false;
        }
    }

    firstNormalPublishedTimestamp_ = rootObject.value(JSON_FIRST_NORMAL_PUBLISHED_TIMESTAMP).toString();

    QJsonArray jsonArray;

    // documents
    QJsonObject documentsObject;
    if (getObjectFromJson(rootObject, JSON_DOCUMENTS, documentsObject) == true) {
        // datasheets
        // some older platforms do not have 'datasheets' key and rely on datasheets.csv file instead - set 'mandatory' flag to 'false'
        if (getArrayFromJson(documentsObject, JSON_DATASHEETS, false, jsonArray) == false) {
            return false;
        }
        populateDatasheetList(jsonArray, datasheetsList_);

        // downloads
        if (getArrayFromJson(documentsObject, JSON_DOWNLOADS, true, jsonArray) == false) {
            return false;
        }
        populateFileList(jsonArray, downloadList_);

        // views
        if (getArrayFromJson(documentsObject, JSON_VIEWS, true, jsonArray) == false) {
            return false;
        }
        populateFileList(jsonArray, viewList_);
    } else {
        // 'documents' object is not mandatory for controller type 'controller'
        if (controllerType != CONTROLLER_TYPE_CONTROLLER) {
            return false;
        }
    }

    // platform selector
    QJsonObject platformSelectorObject;
    if (getObjectFromJson(rootObject, JSON_PLATFORM_SELECTOR, platformSelectorObject) == false) {
        return false;
    }

    if (populateFileObject(platformSelectorObject, platformSelector_) == false) {
        qCCritical(lcHcsPlatformDocument) << this << "value of '" << JSON_PLATFORM_SELECTOR << "' key is not valid";
        return false;
    }

    // name
    name_ = rootObject.value(JSON_NAME).toString();

    // firmware
    if (controllerType != CONTROLLER_TYPE_CONTROLLER) {
        // controller type 'controller' does not have 'firmware' array
        // Nowadays, server does not support firmware object. Make it mandatory when it will be supported.
        if (getArrayFromJson(rootObject, JSON_FIRMWARE, false, jsonArray) == false) {
            return false;
        }
        populateFirmwareList(jsonArray, firmwareList_);
    }

    // control view
    // Nowadays, server does not support control_view object. Make it mandatory when it will be supported.
    // This probably will be mandatory only for 'embedded' and 'assisted' controller type.
    if (getArrayFromJson(rootObject, JSON_CONTROL_VIEW, false, jsonArray) == false) {
        return false;
    }
    populateControlViewList(jsonArray, controlViewList_);

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

const QString PlatformDocument::firstNormalPublishedTimestamp()
{
    return firstNormalPublishedTimestamp_;
}

bool PlatformDocument::getObjectFromJson(const QJsonObject &json, const QString &key, QJsonObject &destObject) const
{
    QJsonObject::const_iterator jsonIter = json.constFind(key);

    if (jsonIter == json.constEnd()) {
        qCCritical(lcHcsPlatformDocument) << this << '\'' << key << "' key is missing";
        return false;
    }

    if (jsonIter->isObject() == false) {
        qCCritical(lcHcsPlatformDocument) << this << "value of '" << key << "' key is not an object";
        return false;
    }

    destObject = jsonIter->toObject();
    return true;
}

bool PlatformDocument::getArrayFromJson(const QJsonObject &json, const QString &key, bool mandatory, QJsonArray &destArray) const
{
    QJsonObject::const_iterator jsonIter = json.constFind(key);

    if (jsonIter == json.constEnd()) {
        if (mandatory) {
            qCCritical(lcHcsPlatformDocument) << this << '\'' << key << "' key is missing";
            return false;
        }
        qCDebug(lcHcsPlatformDocument) << this << '\'' << key << "' key is not present";
        destArray = QJsonArray();
        return true;
    }

    if (jsonIter->isArray()) {
        destArray = jsonIter->toArray();
        return true;
    }

    qCCritical(lcHcsPlatformDocument) << this << "value of '" << key << "' key is not an array";
    return false;
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
