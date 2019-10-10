#pragma once

#include <QObject>
#include <QPluginLoader>

class Green : public QObject {
    Q_OBJECT

public:
    Green() = default;
    Green(const QString reloadPluginFilePath,
          const QString reloadResourceFilePath);
    ~Green() = default;

public slots:
    void onTest(const QString msg);
    void onReload();
    void onRccReload();

private:
    const QString _reloadPluginFilePath;
    const QString _reloadResourceFilePath;
    QPluginLoader _loader;
};
