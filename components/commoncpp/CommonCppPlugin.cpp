#include "CommonCppPlugin.h"

#include "SGUtilsCpp.h"
#include "SGJLinkConnector.h"
#include "SGSortFilterProxyModel.h"
#include "SGQWTPlot.h"
#include "SGUserSettings.h"
#include "SGVersionUtils.h"
#include "SGCSVTableUtils.h"
#include "mqtt/SGMqttClient.h"
#include "mqtt/SGSslConfiguration.h"
#include "SGJsonSyntaxHighlighter.h"
#include "SGJsonFormatter.h"
#include "SGTranslator.h"
#include "SGTextHighlighter.h"
#include "SGConversion.h"

#include <QtQml/qqml.h>

void CommonCppPlugin::registerTypes(const char *uri)
{
    qmlRegisterSingletonType<SGUtilsCpp>(uri, 1, 0,"SGUtilsCpp", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject* {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)

        SGUtilsCpp *utils = new SGUtilsCpp();
        return utils;
    });

    qmlRegisterSingletonType<SGJsonFormatter>(uri, 1, 0,"SGJsonFormatter", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject* {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)

        SGJsonFormatter *formatter = new SGJsonFormatter();
        return formatter;
    });

    qmlRegisterSingletonType<SGCSVTableUtils>(uri, 1, 0,"SGCSVTableUtils", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject* {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)

        SGCSVTableUtils *csvTableUtils = new SGCSVTableUtils();
        return csvTableUtils;
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
    qmlRegisterType<SGTranslator>(uri, 1, 0, "SGTranslator");
    qmlRegisterType<SGTextHighlighter>(uri, 1, 0, "SGTextHighlighter");
    qmlRegisterSingletonType<SGConversion>(uri, 1, 0,"SGConversion", SGConversion::singletonTypeProvider);
}
