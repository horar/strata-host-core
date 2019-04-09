#include "UpdatesPlugin.h"

#include <QDebug>

UpdatesPlugin::UpdatesPlugin() /*override*/ {
    qDebug() << Q_FUNC_INFO << "LOADING...";
    //Q_INIT_RESOURCE(UpdatesPlugin);

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

UpdatesPlugin::~UpdatesPlugin() {
    qDebug() << Q_FUNC_INFO << "UNLOADING...";
    //    Q_CLEANUP_RESOURCE(UpdatesPlugin);

    //    QDirIterator it(":", QDirIterator::Subdirectories);
    //    while (it.hasNext()) {
    //        qDebug() << it.next();
    //    }
}

UpdatesPlugin *UpdatesPlugin::getMyObj() { return this; }

void UpdatesPlugin::doSomething()
{
    const QString msg{QStringLiteral("hot dog!!")};
    qDebug() << Q_FUNC_INFO << "hot dog!!";

    emit dddd(msg);

    //Q_CLEANUP_RESOURCE(UpdatesPlugin);
}
