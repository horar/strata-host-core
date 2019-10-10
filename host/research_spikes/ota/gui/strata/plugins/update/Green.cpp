#include "Green.h"

#include <QResource>
#include <QDebug>

Green::Green(const QString reloadPluginFilePath, const QString reloadResourceFilePath): _reloadPluginFilePath(std::move(reloadPluginFilePath)), _reloadResourceFilePath(std::move(reloadResourceFilePath))
{
}

void Green::onTest(const QString msg) {
    qDebug() << Q_FUNC_INFO << "yeah!! got notified from plugin:'" << msg << "' :)";
}

#include <QDirIterator>
void Green::onReload()
{
    qDebug() << Q_FUNC_INFO << "--->" << _reloadPluginFilePath;
    qDebug() << Q_FUNC_INFO << "isLib:" << QLibrary::isLibrary(_reloadPluginFilePath);
    qDebug() << Q_FUNC_INFO << "isLoa:" << _loader.isLoaded();
    qDebug() << Q_FUNC_INFO << "unloa:" << _loader.unload();
    _loader.setFileName(_reloadPluginFilePath);
    qDebug() << Q_FUNC_INFO << "load :" << _loader.load();
    qDebug() << Q_FUNC_INFO << "isLoa:" << _loader.isLoaded();
}

void Green::onRccReload()
{
    qDebug() << Q_FUNC_INFO << "--->" << _reloadResourceFilePath;
    qDebug() << Q_FUNC_INFO << "unrr:" << QResource::unregisterResource(_reloadResourceFilePath);
    qDebug() << Q_FUNC_INFO << "regr:" << QResource::registerResource(_reloadResourceFilePath);
    qDebug() << Q_FUNC_INFO << "...traversing existing qml resources";
    QDirIterator it(":", QDirIterator::Subdirectories);
    while (it.hasNext()) {
        const auto resource{it.next()};
        if (!resource.startsWith(QStringLiteral(":/qt-project.org"))) {
            qDebug() << Q_FUNC_INFO << "=====>" << resource;
        }
    }
    qDebug() << Q_FUNC_INFO << "...DONE";
}
