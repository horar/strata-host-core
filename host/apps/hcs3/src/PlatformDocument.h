
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

struct FirmwareItem {
    QString partialUri;
    QString md5;
    QString name;
    QString timestamp;
    QString version;
};

QDebug operator<<(QDebug dbg, const PlatformFileItem &item);

class PlatformDocument
{
public:
    PlatformDocument(const QString &classId);

    bool parseDocument(const QString &document);
    QString classId();
    const QList<PlatformFileItem>& getViewList();
    const QList<PlatformFileItem>& getDownloadList();
    const QList<FirmwareItem>& getFirmwareList();
    const PlatformFileItem& platformSelector();

private:
    QString classId_;
    QString name_;
    QList<PlatformFileItem> downloadList_;
    QList<PlatformFileItem> viewList_;
    QList<FirmwareItem> firmwareList_;
    PlatformFileItem platformSelector_;

    bool populateFileObject(const QJsonObject& jsonObject, PlatformFileItem &file);
    void populateFileList(const QJsonArray &jsonList, QList<PlatformFileItem> &fileList);

    bool populateFirmwareObject(const QJsonObject& jsonObject, FirmwareItem &firmware);
    void populateFirmwareList(const QJsonArray &jsonList, QList<FirmwareItem> &firmwareList);
};

#endif //PLATFORM_DOCUMENT_H
