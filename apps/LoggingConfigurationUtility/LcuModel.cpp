/***************************************************************************
 *                                                                         *
 *   Copyright (C) 2021 by ONsemiconductor     *
 *                                                                         *
 *   http://onsemi.com                                          *
 *                                                                         *
 ***************************************************************************/
#include "LcuModel.h"
#include "logging/LoggingQtCategories.h"
#include <QCoreApplication>

LcuModel::LcuModel(QObject *parent)
    : QObject(parent)
{

}
LcuModel::~LcuModel()
{

}
void LcuModel::configFileSelectionChanged(QString fileName)
{
    qCInfo(logCategoryLoggingConfigurationUtility()) << "Selected INI file changed to: " << fileName;
}
