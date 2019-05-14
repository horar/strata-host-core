#ifndef SGUTILS_H
#define SGUTILS_H

#include <QObject>
#include <QQmlEngine>
#include <QJSEngine>

class SgUtils : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SgUtils)

public:
    explicit SgUtils(QObject *parent = nullptr);
    virtual ~SgUtils();

    Q_INVOKABLE QString urlToPath(const QUrl &url);
    Q_INVOKABLE bool isFile(const QString &file);
    Q_INVOKABLE bool atomicWrite(const QString &path, const QString &content);
};

static QObject *sgUtilsSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    SgUtils *utils = new SgUtils();
    return utils;
}


#endif  // SGUTILS_H
