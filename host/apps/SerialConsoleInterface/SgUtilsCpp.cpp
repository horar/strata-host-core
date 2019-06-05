#include "SgUtilsCpp.h"

#include <QFileInfo>
#include <QUrl>
#include <QSaveFile>
#include <QTextStream>
#include <QDebug>

SgUtilsCpp::SgUtilsCpp(QObject *parent)
    : QObject(parent)
{

}

SgUtilsCpp::~SgUtilsCpp()
{

}

QString SgUtilsCpp::urlToPath(const QUrl &url)
{
    return QUrl(url).path();
}

bool SgUtilsCpp::isFile(const QString &file)
{
    QFileInfo info(file);
    return info.isFile();
}

bool SgUtilsCpp::isExecutable(const QString &file)
{
    QFileInfo info(file);
    return info.isExecutable();
}

bool SgUtilsCpp::atomicWrite(const QString &path, const QString &content)
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
