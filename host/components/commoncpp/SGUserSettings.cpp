#include "SGUserSettings.h"
#include "SGUtilsCpp.h"
#include "logging/LoggingQtCategories.h"

#include <QStandardPaths>
#include <QFile>
#include <QJsonDocument>
#include <QJsonValue>
#include <QDirIterator>
#include <QDir>
#include <QDebug>

SGUserSettings::SGUserSettings(QObject *parent, const QString &classId) : QObject(parent), classId_(classId)
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

    qDebug(logCategoryUserSettings) << "Writing to path : " << filePath;

    QJsonDocument doc(data);

    return utils.atomicWrite(filePath, doc.toJson());
}

QJsonObject SGUserSettings::readFile(const QString &fileName, const QString &subdirectory)
{
    SGUtilsCpp utils;
    QString filePath = utils.joinFilePath(base_output_path_, subdirectory);

    filePath = utils.joinFilePath(filePath, fileName);

    QJsonObject returnedObj;

    QString fileText = utils.readTextFileContent(filePath);


    if (!fileText.isEmpty()) {
        QJsonDocument doc = QJsonDocument::fromJson(fileText.toUtf8());

        if (!doc.isNull() && doc.isObject()) {
            returnedObj = doc.object();
        } else {
            qCCritical(logCategoryUserSettings) << "unable to convert document to object";
        }
    } else {
        qCCritical(logCategoryUserSettings) << "document at " << filePath << " is not valid JSON";
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

    qDebug(logCategoryUserSettings) << filesInDir;

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

    qDebug(logCategoryUserSettings) << "Successfully deleted user setting located at " << filePath;

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
        qCCritical(logCategoryUserSettings) << "could not rename file from " << oldFilePath << " to " << newFilePath;
        return false;
    }

    qDebug(logCategoryUserSettings) << "Successfully renamed " << oldFilePath << " to " << newFilePath;

    return true;
}

QString SGUserSettings::getBaseOutputPath()
{
    return base_output_path_;
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

void SGUserSettings::setBaseOutputPath()
{
    SGUtilsCpp utils;
    const QString appDataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    base_output_path_ = utils.joinFilePath(appDataPath, "settings");

    if (!classId_.isNull() && !classId_.isEmpty()) {
        base_output_path_ = utils.joinFilePath(base_output_path_, classId_);
    }
}
