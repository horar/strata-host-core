
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
};

struct FirmwareFileItem {
    QString partialUri;
    QString controllerClassDevice;
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

QDebug operator<<(QDebug dbg, const PlatformFileItem &item);

class PlatformDocument
{
public:
    PlatformDocument(const QString &classId);

    bool parseDocument(const QString &document);
    QString classId();
    const QList<PlatformFileItem>& getViewList();
    const QList<PlatformDatasheetItem>& getDatasheetList();
    const QList<PlatformFileItem>& getDownloadList();
    const QList<FirmwareFileItem>& getFirmwareList();
    const QList<ControlViewFileItem>& getControlViewList();
    const PlatformFileItem& platformSelector();

private:
    QString classId_;
    QString name_;
    QList<PlatformDatasheetItem> datasheetsList_;
    QList<PlatformFileItem> downloadList_;
    QList<PlatformFileItem> viewList_;
    QList<FirmwareFileItem> firmwareList_;
    QList<ControlViewFileItem> controlViewList_;
    PlatformFileItem platformSelector_;

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
