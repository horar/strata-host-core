/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef PLATFORM_DOCUMENT_H
#define PLATFORM_DOCUMENT_H

#include <QMap>
#include <QDebug>

struct PlatformFileItem {
    QString partialUri;
    QString name;
    QString prettyName;
    QString md5;
    QString timestamp;
    qint64 filesize;

    friend QDebug operator<<(QDebug dbg, const PlatformFileItem &item);
};

struct FirmwareFileItem {
    QString partialUri;
    QString controllerClassId;
    QString md5;
    QString timestamp;
    QString version;
};

struct ControlViewFileItem {
    QString partialUri;
    QString md5;
    QString name;
    QString timestamp;
    QString version;
};

struct PlatformDatasheetItem {
    QString category;
    QString datasheet;
    QString name;
    QString opn;
    QString subcategory;
};

class PlatformDocument
{
public:
    friend QDebug operator<<(QDebug dbg, const PlatformDocument* platfDoc);

    PlatformDocument(const QString &classId);

    bool parseDocument(const QByteArray &document);
    QString classId();
    const QList<PlatformFileItem>& getViewList();
    const QList<PlatformDatasheetItem>& getDatasheetList();
    const QList<PlatformFileItem>& getDownloadList();
    const QList<FirmwareFileItem>& getFirmwareList();
    const QList<ControlViewFileItem>& getControlViewList();
    const PlatformFileItem& platformSelector();
    const QString firstNormalPublishedTimestamp();

private:
    QString classId_;
    QString name_;
    QString firstNormalPublishedTimestamp_;
    QList<PlatformDatasheetItem> datasheetsList_;
    QList<PlatformFileItem> downloadList_;
    QList<PlatformFileItem> viewList_;
    QList<FirmwareFileItem> firmwareList_;
    QList<ControlViewFileItem> controlViewList_;
    PlatformFileItem platformSelector_;

    bool getObjectFromJson(const QJsonObject &json, const QString &key, QJsonObject &destObject) const;
    bool getArrayFromJson(const QJsonObject &json, const QString &key, bool mandatory, QJsonArray &destArray) const;

    bool populateFileObject(const QJsonObject& jsonObject, PlatformFileItem &file);
    void populateFileList(const QJsonArray &jsonList, QList<PlatformFileItem> &fileList);

    bool populateFirmwareObject(const QJsonObject& jsonObject, FirmwareFileItem &firmwareFile);
    void populateFirmwareList(const QJsonArray &jsonList, QList<FirmwareFileItem> &firmwareList);

    bool populateControlViewObject(const QJsonObject& jsonObject, ControlViewFileItem &controlViewFile);
    void populateControlViewList(const QJsonArray &jsonList, QList<ControlViewFileItem> &controlViewList);

    bool populateDatasheetObject(const QJsonObject &jsonObject, PlatformDatasheetItem &datasheet);
    void populateDatasheetList(const QJsonArray &jsonList, QList<PlatformDatasheetItem> &datasheetList);
};

#endif //PLATFORM_DOCUMENT_H
