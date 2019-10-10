#pragma once

#include "UpdatesPluginInterface.h"

#include <QObject>
#include <QtPlugin>

//#include <QQmlExtensionPlugin>

#include <QtQml>

#include <QDebug>

class UpdatesPlugin : public QObject, public UpdatesPluginInterface//, public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID UpdatesPluginInterface_iid)
    Q_INTERFACES(UpdatesPluginInterface)

public:
    UpdatesPlugin();
    virtual ~UpdatesPlugin();

    UpdatesPlugin* getMyObj() override;
    // getVersion
    // getName
    // getDescription

//    void registerTypes(const char *uri) /*override*/
//    {
//        qDebug() << " ... register...";
//        Q_ASSERT(uri == QLatin1String("UpdatesPlugin"));
//        qmlRegisterType<UpdatesPlugin>(uri, 1, 0, "UpdatesPlugin");
//    }

    void doSomething() /*const*/ override;

signals:
    void dddd(const QString msg) final;
};
