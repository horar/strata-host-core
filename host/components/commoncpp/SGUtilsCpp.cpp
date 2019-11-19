#include "SGUtilsCpp.h"
#include "logging/LoggingQtCategories.h"

#include <QFileInfo>
#include <QUrl>
#include <QSaveFile>
#include <QTextStream>
#include <QDebug>
#include <QDir>

SGUtilsCpp::SGUtilsCpp(QObject *parent)
    : QObject(parent)
{
}

SGUtilsCpp::~SGUtilsCpp()
{
}

QString SGUtilsCpp::urlToLocalFile(const QUrl &url)
{
    return QDir::toNativeSeparators(QUrl(url).toLocalFile());
}

bool SGUtilsCpp::isFile(const QString &file)
{
    QFileInfo info(file);
    return info.isFile();
}

bool SGUtilsCpp::isExecutable(const QString &file)
{
    QFileInfo info(file);
    return info.isExecutable();
}

QString SGUtilsCpp::fileName(const QString &file)
{
    QFileInfo fi(file);
    return fi.fileName();
}

QString SGUtilsCpp::fileAbsolutePath(const QString &file)
{
    QFileInfo fi(file);
    return fi.absolutePath();
}

QUrl SGUtilsCpp::pathToUrl(const QString &path, const QString &scheme)
{
    QUrl url;
    url.setScheme(scheme);
    url.setPath(path);

    return url;
}

bool SGUtilsCpp::atomicWrite(const QString &path, const QString &content)
{
    QSaveFile file(path);

    bool ret = file.open(QIODevice::WriteOnly | QIODevice::Text);
    if (ret == false) {
        qCWarning(logCategoryUtils) << "cannot open file" << path << file.errorString();
        return false;
    }

    QTextStream out(&file);

    out << content;

    return file.commit();
}

QString SGUtilsCpp::readTextFileContent(const QString &path)
{
    QFile file(path);
    if (file.open(QFile::ReadOnly | QFile::Text) == false) {
        qCWarning(logCategoryUtils) << "cannot open file" << path << file.errorString();
        return QString();
    }

    return file.readAll();
}

QByteArray SGUtilsCpp::toBase64(const QByteArray &text)
{
    return text.toBase64();
}

QByteArray SGUtilsCpp::fromBase64(const QByteArray &text)
{
    return QByteArray::fromBase64(text);
}

QString SGUtilsCpp::joinFilePath(const QString &path, const QString &fileName)
{
    QDir dir(path);
    return dir.filePath(fileName);
}
