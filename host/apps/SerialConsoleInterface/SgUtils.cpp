#include "SgUtils.h"

#include <QFileInfo>
#include <QUrl>
#include <QSaveFile>
#include <QTextStream>
#include <QDebug>

SgUtils::SgUtils(QObject *parent)
    : QObject(parent)
{

}

SgUtils::~SgUtils()
{

}

QString SgUtils::urlToPath(const QUrl &url)
{
    return QUrl(url).path();
}

bool SgUtils::isFile(const QString &file)
{
    QFileInfo info(file);
    return info.isFile();
}

bool SgUtils::atomicWrite(const QString &path, const QString &content)
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
