#include "CommonCppPlugin.h"
#include <QtQml/qqml.h>
#include <QDebug>

#include "SGUtilsCpp.h"
#include "SGJLinkConnector.h"
#include "SGSortFilterProxyModel.h"

void CommonCppPlugin::registerTypes(const char *uri)
{
    qmlRegisterSingletonType<SGUtilsCpp>(uri, 1, 0,"SGUtilsCpp", sgUtilsCppSingletonProvider);
    qmlRegisterType<SGJLinkConnector>(uri, 1, 0, "SGJLinkConnector");
    qmlRegisterType<SGSortFilterProxyModel>(uri, 1, 0, "SGSortFilterProxyModel");
}
