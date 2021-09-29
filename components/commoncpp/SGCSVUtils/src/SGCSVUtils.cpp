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

void SGCSVUtils::appendRow(QVariantList data)
{
    data_.append(data);
}

QVariantList SGCSVUtils::importFromFile(QString folderPath)
{
    SGUtilsCpp utils;
    QString path = utils.urlToLocalFile(folderPath);
    if (!utils.exists(path)) {
        qCInfo(logCategoryCsvUtils) << "This file does not exist";
        return QVariantList();
    }
    data_.clear();
    QStringList data = utils.readTextFileContent(path).split("\n");
    for (QString d: data.toVector()) {
        QVariant line = d.split(",");
        QVariantList eachItem;
        for (QVariant member: line.toList()) {
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

void SGCSVUtils::setData(QVariantList data)
{
    if (data_ != data.toVector()) {
        data_ = data.toVector();
    }
}

void SGCSVUtils::writeToFile()
{
    if (outputPath_.length() == 0 || fileName_.length() == 0) {
        qCInfo(logCategoryCsvUtils) << "To write to file, the output path and the file name cannot be empty";
        return;
    }

    SGUtilsCpp utils;
    QString filePath = utils.joinFilePath(outputPath_, fileName_);
    QString path = utils.urlToLocalFile(filePath);
    if (!utils.exists(path)) {
        utils.createFile(path);
    }
    QString data = "";
    for (QVariant lines: data_) {
        for (QVariant d: lines.toList()) {
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
