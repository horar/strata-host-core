/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
    Q_INVOKABLE static QString fileBaseName(const QString &filename);
    Q_INVOKABLE static QString parentDirectoryPath(const QString &filepath);
    Q_INVOKABLE static bool exists(const QString &filepath);
    Q_INVOKABLE static bool fileIsChildOfDir(const QString &filePath, QString dirPath);
    Q_INVOKABLE static QString urlToLocalFile(const QUrl &url, const bool toNativeSeparators = true);
    Q_INVOKABLE bool isFile(const QString &file);
    Q_INVOKABLE bool isValidFile(const QString &file);
    Q_INVOKABLE bool isValidImage(const QString &file);
    Q_INVOKABLE bool isExecutable(const QString &file);
    Q_INVOKABLE bool isRelative(const QString &file);
    Q_INVOKABLE bool containsForbiddenCharacters(const QString &fileName);
    Q_INVOKABLE QString fileName(const QString &file);
    Q_INVOKABLE QString fileAbsolutePath(const QString &file);
    Q_INVOKABLE QString dirName(const QString &path);
    Q_INVOKABLE QUrl pathToUrl(const QString &path, const QString &scheme=QString("file"));
    Q_INVOKABLE void showFileInFolder(const QString &path);

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
    Q_INVOKABLE QString joinForbiddenCharacters(QString separator = " ");
    Q_INVOKABLE QStringList getForbiddenCharacters();

private:
    const QStringList fileSizePrefixList_;
    const QList<QChar> forbiddenCharactersList_;
};
