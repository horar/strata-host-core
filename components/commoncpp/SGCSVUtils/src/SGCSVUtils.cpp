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

QVariantList SGCSVUtils::getData()
{
    return data_;
}

void SGCSVUtils::appendRow(QVariantList data)
{
    SGUtilsCpp utils;
    QString filePath = utils.joinFilePath(outputPath_, fileName_);
    QString path = utils.urlToLocalFile(filePath);
    if (!utils.exists(path)) {
       utils.createFile(path);
    }
    QVariantList list;
    data_.append(data);
    QString writeData = utils.readTextFileContent(path);
    for (QVariant d: data) {
        writeData += d.toString();
        if (!data.endsWith(d)) {
            writeData += ",";
        }
    }
    writeData += "\n";
    data_.append(writeData);
    utils.atomicWrite(path, writeData);
}

QVariant SGCSVUtils::importFromFile(QString folderPath)
{
    SGUtilsCpp utils;
    QString path = utils.urlToLocalFile(folderPath);
    if (!utils.exists(path)) {
       utils.createFile(path);
    }
    QString readData = utils.readTextFileContent(path);
    data_.clear();
    data_.append(readData);
    return data_;
}

void SGCSVUtils::clear()
{
    data_.clear();
}

void SGCSVUtils::setData(QVariantList data)
{
    if (data_ != data) {
        data_ = data;
    }
}
