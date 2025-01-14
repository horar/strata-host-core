/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SGCSVUtils.h"
#include "SGUtilsCpp.h"
#include "logging/LoggingQtCategories.h"
/**
 * This class is a Utils class that will allow users to export CSV files and import CSV File content.
*/
SGCSVUtils::SGCSVUtils(QObject *parent): QObject(parent)
{

}

SGCSVUtils::~SGCSVUtils()
{
    data_.clear();
}

QVariantList SGCSVUtils::getData()
{
    return data_.toList();
}

void SGCSVUtils::appendRow(const QVariantList data)
{
    data_.append(data);
}

QVariantList SGCSVUtils::importFromFile(const QString &filePath)
{
    QString path = SGUtilsCpp::urlToLocalFile(filePath);
    if (!SGUtilsCpp::exists(path)) {
        qCCritical(lcCsvUtils) << "This file does not exist" << path;
        return QVariantList();
    }
    data_.clear();
    QStringList data = SGUtilsCpp::readTextFileContent(path).split("\n");
    for (const QString &d: data) {
        QVariant line = d.split(",");
        QVariantList eachItem;
        for (QVariant &member: line.toList()) {
            eachItem.append(member);
        }
        QVariant convData = eachItem;
        data_.append(convData);
    }

    return data_.toList();
}

void SGCSVUtils::clear()
{
    data_.clear();
}

void SGCSVUtils::setData(const QVariantList data)
{
    if (data_ != data.toVector()) {
        data_ = data.toVector();
    }
}

void SGCSVUtils::writeToFile(const QString &filePath)
{
    if (filePath.length() == 0) {
        qCCritical(lcCsvUtils) << "To write to file, the file path cannot be empty!";
        return;
    }
    SGUtilsCpp utils;
    QString path = utils.urlToLocalFile(filePath);
    if (!utils.exists(path)) {
        utils.createFile(path);
    }
    QString data = "";
    for (QVariant &lines: data_) {
        for (QVariant &d: lines.toList()) {
            data += d.toString();
            if (!lines.toList().endsWith(d)) {
                data += ",";
            }
        }

        if (!data_.endsWith(lines)) {
            data += "\n";
        }
    }

    utils.atomicWrite(path, data);
}
