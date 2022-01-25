/*
 * Copyright (c) 2018-2022 onsemi.
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
    jsonIter = rootObject.constFind("documents");
    if (jsonIter == rootObject.constEnd()) {
        qCCritical(lcHcsPlatformDocument) << this << "'documents' key is missing";
        return false;
    }

    if (jsonIter->isObject() == false) {
        qCCritical(lcHcsPlatformDocument) << this << "value of 'documents' key is not an object";
        return false;
    }

    const QJsonObject jsonDocument = jsonIter->toObject();

    //datasheets
    jsonIter = jsonDocument.constFind("datasheets");
    if (jsonIter == jsonDocument.constEnd()) {
        qCWarning(lcHcsPlatformDocument) << this << "'datasheets' key is missing";
        // skip - some older platforms rely on datasheets.csv file instead
    } else {
        if (jsonIter->isArray()) {
            populateDatasheetList(jsonIter->toArray(), datasheetsList_);
        } else {
            qCCritical(lcHcsPlatformDocument) << this << "value of 'datasheets' key is not an array";
            return false;
        }
    }

    //downloads
    jsonIter = jsonDocument.constFind("downloads");
    if (jsonIter == jsonDocument.constEnd()) {
        qCCritical(lcHcsPlatformDocument) << this << "'downloads' key is missing";
        return false;
    }

    if (jsonIter->isArray()) {
        populateFileList(jsonIter->toArray(), downloadList_);
    } else {
        qCCritical(lcHcsPlatformDocument) << this << "value of 'downloads' key is not an array";
        return false;
    }

    //views
    jsonIter = jsonDocument.constFind("views");
    if (jsonIter == jsonDocument.constEnd()) {
        qCCritical(lcHcsPlatformDocument) << this << "'views' key is missing";
        return false;
    }

    if (jsonIter->isArray()) {
        populateFileList(jsonIter->toArray(), viewList_);
    } else {
        qCCritical(lcHcsPlatformDocument) << "value of 'views' key is not an array";
        return false;
    }

    //platform selector
    jsonIter = rootObject.constFind("platform_selector");
    if (jsonIter == rootObject.constEnd()) {
        qCCritical(lcHcsPlatformDocument) << this << "'platform_selector' key is missing";
        return false;
    }

    if (jsonIter->isObject() == false) {
        qCCritical(lcHcsPlatformDocument) << this << "value of 'platform_selector' key is not an object";
        return false;
    }

    if (populateFileObject(jsonIter->toObject(), platformSelector_) == false) {
        qCCritical(lcHcsPlatformDocument) << this << "value of 'platform_selector' key is not valid";
        return false;
    }

    //name
    name_ = rootObject.value("name").toString();

    //firmware
    jsonIter = rootObject.constFind("firmware");
    if (jsonIter == rootObject.constEnd()) {
        qCWarning(lcHcsPlatformDocument) << this << "'firmware' key is missing";
        // TODO: Nowadays, server does not support firmware object. Return false when it will be supported.
        //return false;
    }
    else {  // TODO: Remove this else line when server will support firmware object. Do not remove content of else block.
        if (jsonIter->isArray()) {
            populateFirmwareList(jsonIter->toArray(), firmwareList_);
        } else {
            qCCritical(lcHcsPlatformDocument) << this << "value of 'firmware' key is not an array";
            return false;
        }
    }  // TODO: remove this else line

    //control view
    jsonIter = rootObject.constFind("control_view");
     if (jsonIter == rootObject.constEnd()) {
        qCWarning(lcHcsPlatformDocument) << this << "'control_view' key is missing";
        // TODO: Nowadays, server does not support control_view object. Return false when it will be supported.
        //return false;
    }
    else {  // TODO: Remove this else line when server will support control_view object. Do not remove content of else block.
        if (jsonIter->isArray()) {
            populateControlViewList(jsonIter->toArray(), controlViewList_);
        } else {
            qCCritical(lcHcsPlatformDocument) << this << "value of 'control_view' key is not an array";
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

bool PlatformDocument::populateFirmwareObject(const QJsonObject &jsonObject, FirmwareFileItem &firmwareFile)
{
    uint flags = 0x00;
    bool success = false;

    // clang-format off
    if (jsonObject.contains("file"))                  { flags |= 0x01; }  // 00001
    if (jsonObject.contains("controller_class_id"))   { flags |= 0x02; }  // 00010
    if (jsonObject.contains("md5"))                   { flags |= 0x04; }  // 00100
    if (jsonObject.contains("timestamp"))             { flags |= 0x08; }  // 01000
    if (jsonObject.contains("version"))               { flags |= 0x10; }  // 10000
    // clang-format on

    switch (flags) {
    case 0x1F :
        firmwareFile.controllerClassId = jsonObject.value("controller_class_id").toString();
        //fallthrough
    case 0x1D :
        firmwareFile.partialUri = jsonObject.value("file").toString();
        firmwareFile.md5 = jsonObject.value("md5").toString();
        firmwareFile.timestamp = jsonObject.value("timestamp").toString();
        firmwareFile.version = jsonObject.value("version").toString();
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
    if (jsonObject.contains("file") == false
            || jsonObject.contains("md5") == false
            || jsonObject.contains("name") == false
            || jsonObject.contains("timestamp") == false
            || jsonObject.contains("version") == false)
    {
        return false;
    }

    controlViewFile.partialUri = jsonObject.value("file").toString();
    controlViewFile.md5 = jsonObject.value("md5").toString();
    controlViewFile.name = jsonObject.value("name").toString();
    controlViewFile.timestamp = jsonObject.value("timestamp").toString();
    controlViewFile.version = jsonObject.value("version").toString();

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
            qCCritical(lcHcsPlatformDocument) << this << "datasheet object not valid";
            continue;
        }

        datasheetList.append(datasheet);
    }
}
