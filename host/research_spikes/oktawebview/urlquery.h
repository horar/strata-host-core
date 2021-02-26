#ifndef URLQUERY_H
#define URLQUERY_H

#include <QObject>
#include <QString>
#include <QUrl>

class UrlQuery : public QObject
{
    Q_OBJECT
public:
    explicit UrlQuery(QObject *parent = nullptr);
    Q_INVOKABLE QString queryItemValue(QUrl url, QString key);
signals:

};

#endif // URLQUERY_H
