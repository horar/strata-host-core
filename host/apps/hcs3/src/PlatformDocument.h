
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

QDebug operator<<(QDebug dbg, const PlatformFileItem &item);

class PlatformDocument
{
public:
    PlatformDocument(const QString &classId);

    bool parseDocument(const QString &document);
    QString classId();
    const QList<PlatformFileItem>& getViewList();
    const QList<PlatformFileItem>& getDownloadList();
    const PlatformFileItem& platformSelector();

private:
    QString classId_;
    QString name_;
    QList<PlatformFileItem> downloadList_;
    QList<PlatformFileItem> viewList_;
    PlatformFileItem platformSelector_;

    bool populateFileObject(const QJsonObject& jsonObject, PlatformFileItem &file);
    void populateFileList(const QJsonArray &jsonList, QList<PlatformFileItem> &fileList);
};

#endif //PLATFORM_DOCUMENT_H
