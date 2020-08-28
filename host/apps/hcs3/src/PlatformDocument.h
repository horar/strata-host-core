
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

struct VersionedFileItem {
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
    const QList<VersionedFileItem>& getFirmwareList();
    const QList<VersionedFileItem>& getControlViewList();
    const PlatformFileItem& platformSelector();

private:
    QString classId_;
    QString name_;
    QList<PlatformDatasheetItem> datasheetsList_;
    QList<PlatformFileItem> downloadList_;
    QList<PlatformFileItem> viewList_;
    QList<VersionedFileItem> firmwareList_;
    QList<VersionedFileItem> controlViewList_;
    PlatformFileItem platformSelector_;

    bool populateFileObject(const QJsonObject& jsonObject, PlatformFileItem &file);
    void populateFileList(const QJsonArray &jsonList, QList<PlatformFileItem> &fileList);

    bool populateVersionedObject(const QJsonObject& jsonObject, VersionedFileItem &versionedFile);
    void populateVersionedList(const QJsonArray &jsonList, QList<VersionedFileItem> &versionedList);
    bool populateDatasheetObject(const QJsonObject &jsonObject, PlatformDatasheetItem &datasheet);
    void populateDatasheetList(const QJsonArray &jsonList, QList<PlatformDatasheetItem> &datasheetList);
};

#endif //PLATFORM_DOCUMENT_H
