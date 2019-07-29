#ifndef SGUTILSCPP_H
#define SGUTILSCPP_H

#include <QObject>
#include <QQmlEngine>
#include <QJSEngine>

class SgUtilsCpp : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SgUtilsCpp)

public:
    explicit SgUtilsCpp(QObject *parent = nullptr);
    virtual ~SgUtilsCpp();

    Q_INVOKABLE QString urlToPath(const QUrl &url);
    Q_INVOKABLE bool isFile(const QString &file);
    Q_INVOKABLE bool atomicWrite(const QString &path, const QString &content);
};

static QObject *sgUtilsCppSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    SgUtilsCpp *utils = new SgUtilsCpp();
    return utils;
}


#endif  // SGUTILSCPP_H
