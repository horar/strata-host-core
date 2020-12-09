#include "CommonCppPlugin.h"

#include "SGUtilsCpp.h"
#include "SGJLinkConnector.h"
#include "SGSortFilterProxyModel.h"
#include "SGQWTPlot.h"
#include "SGUserSettings.h"
#include "SGVersionUtils.h"
#include "mqtt/SGMqttClient.h"
#include "mqtt/SGSslConfiguration.h"
#include "SGJsonSyntaxHighlighter.h"

#include <QtQml/qqml.h>

void CommonCppPlugin::registerTypes(const char *uri)
{
    qmlRegisterSingletonType<SGUtilsCpp>(uri, 1, 0,"SGUtilsCpp", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject* {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)

        SGUtilsCpp *utils = new SGUtilsCpp();
        return utils;
    });
    qmlRegisterType<SGJLinkConnector>(uri, 1, 0, "SGJLinkConnector");
    qmlRegisterType<SGSortFilterProxyModel>(uri, 1, 0, "SGSortFilterProxyModel");
    qmlRegisterType<SGQWTPlot>(uri, 1, 0, "SGQWTPlot");
    qmlRegisterType<SGQWTPlotCurve>(uri, 1, 0, "SGQWTPlotCurve");
    qmlRegisterType<SGUserSettings>(uri, 1, 0, "SGUserSettings");
    qmlRegisterType<QmlMqttClient>(uri, 1, 0, "SGMqttClient");
    qmlRegisterUncreatableType<QmlMqttSubscription>(uri, 1, 0, "SGMqttSubscription", QLatin1String("Subscriptions are read-only"));
    qmlRegisterType<QmlSslConfiguration>(uri, 1, 0, "SGSslConfiguration");
    qmlRegisterSingletonType<SGVersionUtils>(uri, 1, 0, "SGVersionUtils", SGVersionUtils::SingletonTypeProvider);
    qmlRegisterType<SGJsonSyntaxHighlighter>(uri, 1, 0, "SGJsonSyntaxHighlighter");
}
