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

    Q_INVOKABLE static QString urlToLocalFile(const QUrl &url);
    Q_INVOKABLE static bool isFile(const QString &file);
    Q_INVOKABLE static bool createFile(const QString &filepath);
    Q_INVOKABLE static bool removeFile(const QString &filepath);
    Q_INVOKABLE static bool copyFile(const QString &fromPath, const QString &toPath);
    Q_INVOKABLE static QString fileSuffix(const QString &filename);
    Q_INVOKABLE static bool isExecutable(const QString &file);
    Q_INVOKABLE static QString fileName(const QString &file);
    Q_INVOKABLE static QString fileAbsolutePath(const QString &file);
    Q_INVOKABLE static QString dirName(const QString &path);
    Q_INVOKABLE static QString parentDirectoryPath(const QString &filepath);
    Q_INVOKABLE static QUrl pathToUrl(const QString &path, const QString &scheme=QString("file"));
    Q_INVOKABLE static bool fileIsChildOfDir(const QString &filePath, QString dirPath);

    Q_INVOKABLE bool atomicWrite(const QString &path, const QString &content);
    Q_INVOKABLE QString readTextFileContent(const QString &path);
    Q_INVOKABLE QByteArray toBase64(const QByteArray &text);
    Q_INVOKABLE QByteArray fromBase64(const QByteArray &text);
    Q_INVOKABLE static QString joinFilePath(const QString &path, const QString &fileName);
    Q_INVOKABLE QString formattedDataSize(qint64 bytes, int precision = 1);
    Q_INVOKABLE QString formatDateTimeWithOffsetFromUtc(const QDateTime &dateTime, const QString &format=QString("yyyy-MM-dd hh:mm:ss.zzz t"));

private:
    const QStringList fileSizePrefixList_;
};

#endif  // SGUTILSCPP_H
