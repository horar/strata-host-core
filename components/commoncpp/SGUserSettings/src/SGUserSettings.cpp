/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SGUserSettings.h"
#include "SGUtilsCpp.h"
#include "logging/LoggingQtCategories.h"

#include <QStandardPaths>
#include <QFile>
#include <QJsonDocument>
#include <QDirIterator>
#include <QDir>

SGUserSettings::SGUserSettings(QObject *parent, const QString &user, const QString &classId) : QObject(parent), classId_(classId), user_(user)
{
    setBaseOutputPath();
}

SGUserSettings::~SGUserSettings()
{
}

bool SGUserSettings::writeFile(const QString &fileName, const QJsonObject &data, const QString &subdirectory)
{
    QString filePath = SGUtilsCpp::joinFilePath(base_output_path_, subdirectory);
    makePath(filePath);
    filePath = SGUtilsCpp::joinFilePath(filePath, fileName);
    qCDebug(lcUserSettings) << "Writing to" << filePath;
    QJsonDocument doc(data);
    qCDebug(lcUserSettings) << "writting data:" << doc.toJson(QJsonDocument::Compact);

    return SGUtilsCpp::atomicWrite(filePath, doc.toJson());
}

QJsonObject SGUserSettings::readFile(const QString &fileName, const QString &subdirectory)
{
    QString filePath = SGUtilsCpp::joinFilePath(base_output_path_, subdirectory);
    QJsonObject returnedObj;

    filePath = SGUtilsCpp::joinFilePath(filePath, fileName);

    QFileInfo fi(filePath);
    if (fi.exists() == false || fi.isFile() == false) {
        qCWarning(lcUserSettings) << "Settings file at" << filePath << "does not exist or is not a file.";
        return returnedObj;
    }

    QString fileText = SGUtilsCpp::readTextFileContent(filePath);

    if (!fileText.isEmpty()) {
        QJsonDocument doc = QJsonDocument::fromJson(fileText.toUtf8());

        if (!doc.isNull() && doc.isObject()) {
            returnedObj = doc.object();
            qCDebug(lcUserSettings) << "reading data:" << doc.toJson(QJsonDocument::Compact);
        } else {
            qCCritical(lcUserSettings) << "Unable to convert document to object";
        }
    } else {
        qCCritical(lcUserSettings) << "Document at" << filePath << "is not valid JSON";
    }

    return returnedObj;
}

QStringList SGUserSettings::listFilesInDirectory(const QString &subdirectory)
{
    QString path = SGUtilsCpp::joinFilePath(base_output_path_, subdirectory);

    QStringList filesInDir;

    // Define a directory iterator that only iterates over files.
    QDirIterator it(path, QDir::Files);

    while (it.hasNext()) {
        QFile f = it.next();
        QFileInfo fi(f.fileName());
        filesInDir.append(fi.fileName());
    }

    qCDebug(lcUserSettings) << filesInDir;

    return filesInDir;
}

bool SGUserSettings::deleteFile(const QString &fileName, const QString &subdirectory)
{
    QString filePath = SGUtilsCpp::joinFilePath(base_output_path_, subdirectory);

    filePath = SGUtilsCpp::joinFilePath(filePath, fileName);

    if (!QFile::remove(filePath)) {
        qCCritical(lcUserSettings) << "cannot delete file " << filePath;
        return false;
    }

    qCDebug(lcUserSettings) << "Successfully deleted user setting located at " << filePath;

    return true;
}

bool SGUserSettings::renameFile(const QString &origFileName, const QString &newFileName, const QString &subdirectory)
{
    QString oldFilePath = SGUtilsCpp::joinFilePath(base_output_path_, subdirectory);

    oldFilePath = SGUtilsCpp::joinFilePath(oldFilePath, origFileName);

    QString newFilePath = SGUtilsCpp::joinFilePath(base_output_path_, subdirectory);
    newFilePath = SGUtilsCpp::joinFilePath(newFilePath, newFileName);

    if (!QFile::rename(oldFilePath, newFilePath)) {
        qCCritical(lcUserSettings) << "Could not rename file from" << oldFilePath << "to" << newFilePath;
        return false;
    }

    qCDebug(lcUserSettings) << "Successfully renamed" << oldFilePath << "to" << newFilePath;
    return true;
}

bool SGUserSettings::makePath(const QString &path)
{
    return QDir().mkpath(path);
}

QString SGUserSettings::classId()
{
    return classId_;
}

void SGUserSettings::setClassId(const QString &id)
{
    if (classId_ != id) {
        classId_ = id;
        setBaseOutputPath();
        emit classIdChanged();
    }
}

QString SGUserSettings::user()
{
    return user_;
}

void SGUserSettings::setUser(const QString &user)
{
    if (user_ != user) {
        user_ = user;
        setBaseOutputPath();
        emit userChanged();
    }
}

void SGUserSettings::setBaseOutputPath()
{
    const QString appDataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QString hashedString;
    if (user_ != "") {
        const uint hashedUser = qHash(user_);
        hashedString = QString::number(hashedUser);
    }
    qCDebug(lcUserSettings, "output path user: %s/%s", qUtf8Printable(user_), qUtf8Printable(hashedString));

    base_output_path_ = SGUtilsCpp::joinFilePath(appDataPath, "settings");

    base_output_path_ = SGUtilsCpp::joinFilePath(base_output_path_, hashedString);

    if (!classId_.isNull() && !classId_.isEmpty()) {
        base_output_path_ = SGUtilsCpp::joinFilePath(base_output_path_, classId_);
    }

    qCDebug(lcUserSettings) << "base output path:" << base_output_path_;
}
