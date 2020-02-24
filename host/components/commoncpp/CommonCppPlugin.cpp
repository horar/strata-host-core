#include "CommonCppPlugin.h"

#include "SGUtilsCpp.h"
#include "SGJLinkConnector.h"
#include "SGSortFilterProxyModel.h"
#include "SGQWTPlot.h"

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
}
