#include "url.h"

url::url(QObject *parent) : QObject(parent)
{

}

QString url::getHost(QUrl u)
{
    return u.host();
}
