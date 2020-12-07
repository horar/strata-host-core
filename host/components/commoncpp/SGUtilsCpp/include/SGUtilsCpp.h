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

    Q_INVOKABLE QString urlToLocalFile(const QUrl &url);
    Q_INVOKABLE bool isFile(const QString &file);
    Q_INVOKABLE bool isValidImage(const QString &file);
    Q_INVOKABLE bool isExecutable(const QString &file);
    Q_INVOKABLE QString fileName(const QString &file);
    Q_INVOKABLE QString fileAbsolutePath(const QString &file);
    Q_INVOKABLE QString dirName(const QString &path);
    Q_INVOKABLE QUrl pathToUrl(const QString &path, const QString &scheme=QString("file"));
    Q_INVOKABLE QString returnViewsPath(const QString &filePath);
    Q_INVOKABLE QUrl getViewsFolder();

    Q_INVOKABLE bool atomicWrite(const QString &path, const QString &content);
    Q_INVOKABLE QString readTextFileContent(const QString &path);
    Q_INVOKABLE QByteArray toBase64(const QByteArray &text);
    Q_INVOKABLE QByteArray fromBase64(const QByteArray &text);
    Q_INVOKABLE QString joinFilePath(const QString &path, const QString &fileName);
    Q_INVOKABLE QString formattedDataSize(qint64 bytes, int precision = 1);
    Q_INVOKABLE QString formatDateTimeWithOffsetFromUtc(const QDateTime &dateTime, const QString &format=QString("yyyy-MM-dd hh:mm:ss.zzz t"));
    Q_INVOKABLE static QString generateUuid();
    Q_INVOKABLE static bool validateJson(const QByteArray &json, const QByteArray &schema);
    Q_INVOKABLE static QString toHex(qint64 number, int width = 0);

    /*!
     * Format valid json string.
     * \param json valid json string
     * \param indentSize number of spaces used for indentation
     * \return formatted json string
     */
    Q_INVOKABLE static QByteArray prettifyJson(const QByteArray &json, int indentSize=4);

    /*!
     * Removes all unnecessary white spaces from valid json string.
     * \param json valid json string
     * \return json string without unnecessary spaces
     */
    Q_INVOKABLE static QByteArray minifyJson(const QByteArray &json);

private:
    const QStringList fileSizePrefixList_;
};
