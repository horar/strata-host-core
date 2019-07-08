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

QString SGUtilsCpp::urlToPath(const QUrl &url)
{
    return QUrl(url).path();
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

bool SGUtilsCpp::atomicWrite(const QString &path, const QString &content)
{
    QSaveFile file(path);

    bool ret = file.open(QIODevice::WriteOnly | QIODevice::Text);
    if (ret == false) {
        return false;
    }

    QTextStream out(&file);

    out << content;

    return file.commit();
}
