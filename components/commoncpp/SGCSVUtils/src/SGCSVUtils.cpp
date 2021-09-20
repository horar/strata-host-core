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

QVariant SGCSVUtils::getData()
{
    return data_;
}

void SGCSVUtils::appendRow(QVariant data)
{
    data_.append(data);
    SGUtilsCpp utils;
    QString filePath = utils.joinFilePath(outputPath_, "file.csv");
    QString path = utils.urlToLocalFile(filePath);
    utils.atomicWrite(path, data.toByteArray());

}

QVariant SGCSVUtils::importFromFile(QString folderPath)
{
    SGUtilsCpp utils;
    QString readData = utils.readTextFileContent(folderPath);
    data_.clear();
    QStringList list = readData.split("\n");

    for (QVariant varList: list) {
        data_.append(varList);
    }

    return data_;
}

void SGCSVUtils::clear()
{
    data_.clear();
}

void SGCSVUtils::setData(QVariant data)
{
    if (data_ != data) {
        data_ = data.toList();
    }
}
