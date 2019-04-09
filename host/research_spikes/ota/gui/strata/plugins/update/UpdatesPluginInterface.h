#pragma once

#include <QtPlugin>
//#include <QObject>

class UpdatesPlugin;

class UpdatesPluginInterface/* : public QObject*/ {
//    Q_OBJECT

public:
    virtual ~UpdatesPluginInterface() = default;

//    virtual operator QObject*() = 0;

    virtual UpdatesPlugin* getMyObj() = 0;
    virtual void doSomething() /*const*/ = 0;

signals:
//    void updIf();
    virtual void dddd(const QString msg) = 0;
};


#define UpdatesPluginInterface_iid "tech.spyglass.strata.UpdatesPluginInterface/1.0"
Q_DECLARE_INTERFACE(UpdatesPluginInterface, UpdatesPluginInterface_iid)
