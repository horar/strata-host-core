#pragma once

#include <QtPlugin>
//#include <QObject>

class SgWidgetsPlugin;

class SgWidgetsPluginInterface/* : public QObject*/ {
//    Q_OBJECT

public:
    virtual ~SgWidgetsPluginInterface() = default;

//    virtual operator QObject*() = 0;

    virtual SgWidgetsPlugin* getMyObj() = 0;
    virtual void doSomething() /*const*/ = 0;

signals:
//    void updIf();
    virtual void dddd(const QString msg) = 0;
};


#define SgWidgetsPluginInterface_iid "tech.spyglass.strata.SgWidgetsPluginInterface/1.0"
Q_DECLARE_INTERFACE(SgWidgetsPluginInterface, SgWidgetsPluginInterface_iid)
