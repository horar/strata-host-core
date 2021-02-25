#include "urlquery.h"
#include <QUrlQuery>

UrlQuery::UrlQuery(QObject *parent) : QObject(parent)
{

}

QString UrlQuery::queryItemValue(QUrl url, QString key)
{
    QUrlQuery query(url);
    return query.queryItemValue(key);
}
