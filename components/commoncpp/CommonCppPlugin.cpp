/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "CommonCppPlugin.h"

#include "SGUtilsCpp.h"
#include "SGJLinkConnector.h"
#include "SGSortFilterProxyModel.h"
#include "SGQwtPlot.h"
#include "SGUserSettings.h"
#include "SGVersionUtils.h"
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

    qmlRegisterType<SGJLinkConnector>(uri, 1, 0, "SGJLinkConnector");
    qmlRegisterType<SGSortFilterProxyModel>(uri, 1, 0, "SGSortFilterProxyModel");
    qmlRegisterType<SGQwtPlot>(uri, 1, 0, "SGQwtPlot");
    qmlRegisterType<SGQwtPlotCurve>(uri, 1, 0, "SGQwtPlotCurve");
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
