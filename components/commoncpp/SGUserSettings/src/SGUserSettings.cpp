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
    SGUtilsCpp utils;
    QString filePath = utils.joinFilePath(base_output_path_, subdirectory);
    makePath(filePath);
    filePath = utils.joinFilePath(filePath, fileName);
    qCDebug(logCategoryUserSettings) << "Writing to" << filePath;
    QJsonDocument doc(data);

    return utils.atomicWrite(filePath, doc.toJson());
}

QJsonObject SGUserSettings::readFile(const QString &fileName, const QString &subdirectory)
{
    SGUtilsCpp utils;
    QString filePath = utils.joinFilePath(base_output_path_, subdirectory);
    QJsonObject returnedObj;

    filePath = utils.joinFilePath(filePath, fileName);

    QFileInfo fi(filePath);
    if (fi.exists() == false || fi.isFile() == false) {
        qCWarning(logCategoryUserSettings) << "Settings file at" << filePath << "does not exist or is not a file.";
        return returnedObj;
    }

    QString fileText = utils.readTextFileContent(filePath);

    if (!fileText.isEmpty()) {
        QJsonDocument doc = QJsonDocument::fromJson(fileText.toUtf8());

        if (!doc.isNull() && doc.isObject()) {
            returnedObj = doc.object();
        } else {
            qCCritical(logCategoryUserSettings) << "Unable to convert document to object";
        }
    } else {
        qCCritical(logCategoryUserSettings) << "Document at" << filePath << "is not valid JSON";
    }

    return returnedObj;
}

QStringList SGUserSettings::listFilesInDirectory(const QString &subdirectory)
{
    SGUtilsCpp utils;

    QString path = utils.joinFilePath(base_output_path_, subdirectory);

    QDir dir(path);
    QStringList filesInDir;

    // Define a directory iterator that only iterates over files.
    QDirIterator it(path, QDir::Files);

    while (it.hasNext()) {
        QFile f = it.next();
        QFileInfo fi(f.fileName());
        filesInDir.append(fi.fileName());
    }

    qCDebug(logCategoryUserSettings) << filesInDir;

    return filesInDir;
}

bool SGUserSettings::deleteFile(const QString &fileName, const QString &subdirectory)
{
    SGUtilsCpp utils;
    QString filePath = utils.joinFilePath(base_output_path_, subdirectory);

    filePath = utils.joinFilePath(filePath, fileName);

    if (!QFile::remove(filePath)) {
        qCCritical(logCategoryUserSettings) << "cannot delete file " << filePath;
        return false;
    }

    qCDebug(logCategoryUserSettings) << "Successfully deleted user setting located at " << filePath;

    return true;
}

bool SGUserSettings::renameFile(const QString &origFileName, const QString &newFileName, const QString &subdirectory)
{
    SGUtilsCpp utils;
    QString oldFilePath = utils.joinFilePath(base_output_path_, subdirectory);

    oldFilePath = utils.joinFilePath(oldFilePath, origFileName);

    QString newFilePath = utils.joinFilePath(base_output_path_, subdirectory);
    newFilePath = utils.joinFilePath(newFilePath, newFileName);

    if (!QFile::rename(oldFilePath, newFilePath)) {
        qCCritical(logCategoryUserSettings) << "Could not rename file from" << oldFilePath << "to" << newFilePath;
        return false;
    }

    qCDebug(logCategoryUserSettings) << "Successfully renamed" << oldFilePath << "to" << newFilePath;
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
    SGUtilsCpp utils;
    const QString appDataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QString hashedString;
    if (user_ != "") {
        const uint hashedUser = qHash(user_);
        hashedString = QString::number(hashedUser);
    }

    base_output_path_ = utils.joinFilePath(appDataPath, "settings");

    base_output_path_ = utils.joinFilePath(base_output_path_, hashedString);

    if (!classId_.isNull() && !classId_.isEmpty()) {
        base_output_path_ = utils.joinFilePath(base_output_path_, classId_);
    }

    qCDebug(logCategoryUserSettings) << "Setting base output path for user settings to" << base_output_path_;
}
