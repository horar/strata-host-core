#ifndef SGUTILSCPP_H
#define SGUTILSCPP_H

#include <QObject>
#include <QUrl>

class SGUtilsCpp : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SGUtilsCpp)

public:
    explicit SGUtilsCpp(QObject *parent = nullptr);
    virtual ~SGUtilsCpp();

    Q_INVOKABLE QString urlToLocalFile(const QUrl &url);
    Q_INVOKABLE bool isFile(const QString &file);
    Q_INVOKABLE bool isExecutable(const QString &file);
    Q_INVOKABLE QString fileName(const QString &file);
    Q_INVOKABLE QString fileAbsolutePath(const QString &file);
    Q_INVOKABLE QString dirName(const QString &path);
    Q_INVOKABLE QUrl pathToUrl(const QString &path, const QString &scheme=QString("file"));

    Q_INVOKABLE bool atomicWrite(const QString &path, const QString &content);
    Q_INVOKABLE QString readTextFileContent(const QString &path);
    Q_INVOKABLE QByteArray toBase64(const QByteArray &text);
    Q_INVOKABLE QByteArray fromBase64(const QByteArray &text);
    Q_INVOKABLE QString joinFilePath(const QString &path, const QString &fileName);
    Q_INVOKABLE QString formattedDataSize(qint64 bytes, int precision = 1);
    Q_INVOKABLE QString formatDateTimeWithOffsetFromUtc(const QDateTime &dateTime, const QString &format=QString("yyyy-MM-dd hh:mm:ss.zzz t"));

private:
    const QStringList fileSizePrefixList_;
};

#endif  // SGUTILSCPP_H
