#include "SGCSVUtils.h"
#include "../SGUtilsCpp/include/SGUtilsCpp.h"
#include "QDebug"
/**
 * This class is a Utils class that will allow users to export CSV files and import CSV File content.
*/
SGCSVUtils::SGCSVUtils(QObject *parent): QObject(parent)
{
   outputPath_ = "";
}

SGCSVUtils::~SGCSVUtils()
{
    data_.clear();
}

QString SGCSVUtils::getData()
{
    QString data;
    for (QVariantList list: data_) {
        for (QVariant d: list) {
            data += d.toString();

            if (!list.endsWith(d)) {
               data += ",";
            }
        }
        data += "\n";
    }

    return data;
}

void SGCSVUtils::appendRow(QVariantList data)
{
    data_.append(data);
}

QString SGCSVUtils::importFromFile(QString folderPath)
{
    SGUtilsCpp utils;
    QString path = utils.urlToLocalFile(folderPath);
    if (!utils.exists(path)) {
       utils.createFile(path);
    }
    QStringList readData = utils.readTextFileContent(path).split("\n");
    QVariantList convertedData;

    for (QString data : readData) {
        convertedData.append(data);
    }
    data_.clear();
    data_.append(convertedData);
    return getData();
}

void SGCSVUtils::clear()
{
    data_.clear();
}

void SGCSVUtils::setData(QVector<QVariantList> data)
{
    if (data_ != data) {
        data_ = data;
    }
}

void SGCSVUtils::writeToFile()
{
    SGUtilsCpp utils;
    QString filePath = utils.joinFilePath(outputPath_, fileName_);
    QString path = utils.urlToLocalFile(filePath);
    if (!utils.exists(path)) {
       utils.createFile(path);
    }
    QString data = "";
    for (QVariantList lines: data_) {
        qInfo() << lines;
        for (QVariant d: lines) {
            data += d.toString();
            if(!lines.endsWith(d)) {
                data += ",";
            }
        }
        data += "\n";
    }

    utils.atomicWrite(path, data);
}
