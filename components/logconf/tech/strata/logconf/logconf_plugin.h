#pragma once
#include <QObject>
#include <QtQml/QQmlExtensionPlugin>

class LogConfPlugin : public QQmlExtensionPlugin
{
  Q_OBJECT
  Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
  void registerTypes(const char * uri);
};
