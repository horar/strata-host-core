#include "SgUtils.h"

#include <QFileInfo>
#include <QUrl>

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
