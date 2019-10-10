#pragma once

#include "SgWidgetsPluginInterface.h"

#include <QObject>
#include <QtPlugin>

//#include <QQmlExtensionPlugin>

#include <QtQml>

#include <QDebug>

class SgWidgetsPlugin : public QObject, public SgWidgetsPluginInterface//, public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID SgWidgetsPluginInterface_iid)
    Q_INTERFACES(SgWidgetsPluginInterface)

public:
    SgWidgetsPlugin();
    virtual ~SgWidgetsPlugin();

    SgWidgetsPlugin* getMyObj() override;
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
