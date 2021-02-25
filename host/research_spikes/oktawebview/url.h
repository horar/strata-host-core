#ifndef URL_H
#define URL_H

#include <QObject>
#include <QUrl>
class url : public QObject
{
    Q_OBJECT
public:
    explicit url(QObject *parent = nullptr);
    Q_INVOKABLE QString getHost(QUrl u);
signals:

};

#endif // URL_H
