#include <assert.h>

#include <QDebug>
#include <QPluginLoader>

#include <QGuiApplication>

#include "UpdatesPlugin.h"

#include "Green.h"
#include "EnhancedQmlApplicationEngine.h"


int main(int argc, char* argv[])
{
    QGuiApplication app(argc, argv);

    // ---------------------------------------------------------------------------------------------
    qDebug() << "test - load plugins...";
    auto pluginsDir{QDir(qApp->applicationDirPath())};
    qDebug() << "...from " << pluginsDir.currentPath();

#if defined(Q_OS_WIN)
    if (pluginsDir.dirName().toLower() == "debug" || pluginsDir.dirName().toLower() == "release")
        pluginsDir.cdUp();
#elif defined(Q_OS_MAC)
    if (pluginsDir.dirName() == "MacOS") {
        pluginsDir.cdUp();
        pluginsDir.cdUp();
        pluginsDir.cdUp();
    }
#endif
    //    pluginsDir.cd("plugins");

    qDebug() << "...from " << pluginsDir.currentPath();

    QStringList lastPluginPath4nextTests;
    QStringList lastResourcdPath4nextTests;
    const auto entryList = pluginsDir.entryList(QDir::Files);
    for (const auto& fileName : entryList) {
        qDebug() << "....checking: " << fileName;
        if (QFileInfo(fileName).suffix() == "rcc") {
            // Qt rcc
            lastResourcdPath4nextTests.append(pluginsDir.absoluteFilePath(fileName));
            qDebug() << "rr:" << QResource::registerResource(fileName);
            // ???
            qDebug() << "ur:" << QResource::unregisterResource(fileName);
            continue;
        }
        const auto fullFilePath{pluginsDir.absoluteFilePath(fileName)};
        QPluginLoader loader(fullFilePath);
        QObject *plugin = loader.instance();
        if (plugin) {
            lastPluginPath4nextTests.append(fullFilePath);
            qDebug() << "......ok, plugin:" << plugin;
            //            populateMenus(plugin);
            //            pluginFileNames += fileName;
            qDebug() << "......unloading:" << loader.unload();
        } else {
            qDebug() << "......ee";
        }
    }
    qDebug() << "...done\n\n";

    // ---------------------------------------------------------------------------------------------
    //    // test 2
    //    qDebug() << "test 2";
    //    const auto staticInstances = QPluginLoader::staticInstances();
    //    for (QObject *plugin : staticInstances) {
    //        //        populateMenus(plugin);
    //        qDebug() << "plugin:" << plugin;
    //    }


    // ---------------------------------------------------------------------------------------------
    qDebug() << "test - load qml from plugin...";
    // Green green;
    Green green{lastPluginPath4nextTests.first(), lastResourcdPath4nextTests.first()};

    qDebug() << "plugin static instances: " << QPluginLoader::staticInstances();
    //assert(QLibrary::isLibrary(lastPluginPath4nextTests));
    qDebug() << "is library:" << QLibrary::isLibrary(lastPluginPath4nextTests.last());
    QPluginLoader loader(lastPluginPath4nextTests.last());

    if (auto instance = loader.instance()) {
        if (auto plugin = qobject_cast<UpdatesPluginInterface*>(instance)){
            QObject::connect(dynamic_cast<QObject*>(plugin), SIGNAL(dddd(const QString)),
                             &green, SLOT(onTest(const QString)));

            qDebug() << "let plugin do some work for us...";
            plugin->doSomething();
            qDebug() << "...done" << plugin;
        } else {
            qDebug() << "plugin missmatch: qobject_cast<> returned nullptr" << plugin << ", " << instance;
        }
    } else {
        qDebug() << "loader error:" << loader.errorString();
    }

    qDebug() << "plugin loaded:" << loader.isLoaded();


    // standard app
    int ret{0};
    do {
        qDebug() << "loading qml main window from plugin...";
        EnhancedQmlApplicationEngine engine;
        engine.addImportPath(":/");
        engine.rootContext()->setContextProperty("$QmlEngine", &engine);
        engine.load({QStringLiteral("qrc:/qml/updates/updates.qml")});
        if (engine.rootObjects().isEmpty()) {
            return -1;
        }

        // qml -> green
        QObject::connect(engine.rootObjects().first(), SIGNAL(qmlSignal(QString)),
                         &green, SLOT(onTest(const QString)));

        // reload
        QObject::connect(engine.rootObjects().first(), SIGNAL(qmlSignalReload()),
                         &green, SLOT(onReload()));
        // rcc reload
        QObject::connect(engine.rootObjects().first(), SIGNAL(qmlSignalRccReload()),
                         &green, SLOT(onRccReload()));

        ret = app.exec();
        qDebug() << "ret:" << ret;

        engine.clearComponentCache();
        // TODO: unload plugin & unregister resources (RAII)
    } while (ret == 123);

    qDebug() << "is loaded:" << loader.isLoaded();
    qDebug() << "unload:" << loader.unload();
    qDebug() << "...unloaded qml from plugin:" << !loader.isLoaded();
    //const auto ret{app.exec()};
    return ret;
}
