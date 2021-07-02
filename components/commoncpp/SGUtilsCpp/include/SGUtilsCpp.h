#pragma once

#include <QObject>
#include <QUrl>
#include <QDirIterator>

class SGUtilsCpp : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SGUtilsCpp)

public:
    explicit SGUtilsCpp(QObject *parent = nullptr);
    virtual ~SGUtilsCpp();

    Q_INVOKABLE static bool createFile(const QString &filepath);
    Q_INVOKABLE static bool removeFile(const QString &filepath);
    Q_INVOKABLE static bool copyFile(const QString &fromPath, const QString &toPath);
    Q_INVOKABLE static QString fileSuffix(const QString &filename);
    Q_INVOKABLE static QString parentDirectoryPath(const QString &filepath);
    Q_INVOKABLE static bool exists(const QString &filepath);
    Q_INVOKABLE static bool fileIsChildOfDir(const QString &filePath, QString dirPath);
    Q_INVOKABLE static QString urlToLocalFile(const QUrl &url);
    Q_INVOKABLE bool isFile(const QString &file);
    Q_INVOKABLE bool isValidImage(const QString &file);
    Q_INVOKABLE bool isExecutable(const QString &file);
    Q_INVOKABLE QString fileName(const QString &file);
    Q_INVOKABLE QString fileAbsolutePath(const QString &file);
    Q_INVOKABLE QString dirName(const QString &path);
    Q_INVOKABLE QUrl pathToUrl(const QString &path, const QString &scheme=QString("file"));

    Q_INVOKABLE bool atomicWrite(const QString &path, const QString &content);
    Q_INVOKABLE QString readTextFileContent(const QString &path);
    Q_INVOKABLE QByteArray toBase64(const QByteArray &text);
    Q_INVOKABLE QByteArray fromBase64(const QByteArray &text);
    Q_INVOKABLE static QString joinFilePath(const QString &path, const QString &fileName);
    Q_INVOKABLE QString formattedDataSize(qint64 bytes, int precision = 1);
    Q_INVOKABLE QString formatDateTimeWithOffsetFromUtc(const QDateTime &dateTime, const QString &format=QString("yyyy-MM-dd hh:mm:ss.zzz t"));
    Q_INVOKABLE static QString generateUuid();
    Q_INVOKABLE static bool validateJson(const QByteArray &json, const QByteArray &schema);
    Q_INVOKABLE static QString toHex(qint64 number, int width = 0);
    Q_INVOKABLE static void copyToClipboard(const QString &text);
    Q_INVOKABLE static QString keySequenceNativeText(QString sequence);
    Q_INVOKABLE static bool keySequenceMatches(QString sequence, int key);
    Q_INVOKABLE  QList<QString> getQrcPaths(QString path);

    /* data type conversion of hex string in little endian*/
    Q_INVOKABLE static float hexStringToFloat32(const QByteArray &hexString);
    Q_INVOKABLE static quint16 hexStringToUint16(const QByteArray &hexString);
    Q_INVOKABLE static qint16 hexStringToInt16(const QByteArray &hexString);

    Q_INVOKABLE static QByteArray float32ToHexString(float number);
    Q_INVOKABLE static QByteArray uint16ToHexString(quint16 number);
    Q_INVOKABLE static QByteArray int16ToHexString(qint16 number);

private:
    const QStringList fileSizePrefixList_;
};
