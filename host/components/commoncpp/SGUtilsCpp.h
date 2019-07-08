#ifndef SGUTILSCPP_H
#define SGUTILSCPP_H

#include <QObject>
#include <QQmlEngine>
#include <QJSEngine>

class SGUtilsCpp : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SGUtilsCpp)

public:
    explicit SGUtilsCpp(QObject *parent = nullptr);
    virtual ~SGUtilsCpp();

    Q_INVOKABLE QString urlToPath(const QUrl &url);
    Q_INVOKABLE QString urlToLocalFile(const QUrl &url);
    Q_INVOKABLE bool isFile(const QString &file);
    Q_INVOKABLE bool isExecutable(const QString &file);
    Q_INVOKABLE bool atomicWrite(const QString &path, const QString &content);
};

static QObject *sgUtilsCppSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    SGUtilsCpp *utils = new SGUtilsCpp();
    return utils;
}


#endif  // SGUTILSCPP_H
