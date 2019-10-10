#ifndef COMMONCPPPLUGIN_H
#define COMMONCPPPLUGIN_H

#include <QtQml/QQmlExtensionPlugin>

class CommonCppPlugin: public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    void registerTypes(const char *uri) override;
};

#endif // COMMONCPPPLUGIN_H
