#include "SGCSVTableUtils.h"
#include "../SGUtilsCpp/include/SGUtilsCpp.h"
#include "QDebug"
/**
 * This class is a hybrid model/utils class that utilizes the QAbstractTableModel to build out a csv file.
 * but does not need to be implemented as a model to be used properly.
*/
SGCSVTableUtils::SGCSVTableUtils(QObject *parent): QAbstractTableModel(parent)
{
}
/* This is an overwritten method that in our implementation allows for the number of columns to be defined by the number of headers */
int SGCSVTableUtils::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return headers_.length();
}
/* This is a custom method that inserts in to the table model the headers */
void SGCSVTableUtils::createheaders(QStringList headers)
{
    QMap<int,QString> headerMap;
    foreach(QString header, headers) {
        headerMap.insert(headers.indexOf(header), header);
    }
    map_.insert(rowCount(), headerMap);
}
/* This is an overwritten method that in our implementation returns the data point[row][column] */
QVariant SGCSVTableUtils::data(const QModelIndex &index, int role) const
{
    if (map_.isEmpty()) return  QVariant();

    if (index.column() < 0 || index.column() > columnCount() || index.row() < 0 || index.row() > rowCount() || role != Qt::DisplayRole) {
        return QString();
    }
    return map_.value(index.row()).value(index.column());
}
/* This method converts the backing table model into a csv format so that it can be quickly exported to a file*/
QString SGCSVTableUtils::exportModelToCSV()
{
    QString textData;
    int rows = rowCount();
    int columns = columnCount();

    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < columns; j++) {
            textData += data(index(i,j),Qt::DisplayRole).toString();
            if (j < columns - 1) {
                textData += ";";
            }
        }
        textData += "\n";
    }

    return textData;
}
/* This is the READ for folderPath, where we return the current folderPath*/
QString SGCSVTableUtils::folderPath() const
{
    return folderPath_;
}
/* This is an overwritten method that in our implementation returns the header point at headerPoint[0][column] */
QVariant SGCSVTableUtils::headerData(int section, Qt::Orientation orientation, int role) const
{
    if (role != Qt::DisplayRole || orientation != Qt::Horizontal) {
        return QVariant();
    }

    return map_.value(0).value(section);
}
/* This is an overwritten method that implements the QAbstractTableModel's rowCount to be dynamic */
bool SGCSVTableUtils::insertRows(int row, int count, const QModelIndex &parent)
{
    beginInsertRows(parent,row, row + count - 1);
    rows_ += count;
    endInsertRows();

    return true;
}
/* This is an overwritten method that in our implementation allows for dynamic number of rows */
int SGCSVTableUtils::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return rows_;
}
/* This is the WRITE for folderPath, where we set the FolderPath*/
void SGCSVTableUtils::setFolderPath(QString folderPath)
{
    if (folderPath_ != folderPath) {
        folderPath_ = folderPath;
        emit folderPathChanged();
    }
}
/* This is a custom method that will read in a now convertedData input and append it to the .csv file*/
void SGCSVTableUtils::writeLineToFile(QMap<int, QString> data) {
    QString textDataRow;
    for (int i = 0; i < data.count(); i++) {
        textDataRow += data.value(i);
        if( i < data.count() - 1) {
            textDataRow += ";";
        }
    }
    SGUtilsCpp _utils;
    QUrl url = _utils.joinFilePath(folderPath_, cmdName_+".csv");
    QString path = _utils.urlToLocalFile(url);
    QFile file(path);
    if (file.open(QFile::Append | QFile::Text)) {
        QTextStream out(&file);
        if (file.size() == 0) {
            QString textHeaderRow;
            for (int i = 0; i < headers_.length(); i++) {
                textHeaderRow += headers_.at(i);
                if(i < headers_.length() - 1) {
                    textHeaderRow += ";";
                }
            }
            out << textHeaderRow;
            out << endl;
        }
        out << textDataRow;
        out << endl;
    }
    file.close();
}

/** THESE ARE THE FUNCTIONS THAT A USER CAN CALL FROM QML */
/* This returns the number of headers in the table model */
int SGCSVTableUtils::getHeadersCount() const {
    return headers_.length();
}
/* This is a custom method that imports a .csv file and converts it to a table model */
void SGCSVTableUtils::importTableFromFile(QString folderPath)
{
    clearBackingModel();
    beginResetModel();
    map_.clear();
    endResetModel();
    SGUtilsCpp _utils;
    QStringList fileContent = _utils.readTextFileContent(folderPath).split("\n");
    for (int i = 0; i < fileContent.length(); i++) {
        QStringList lineContent = fileContent.at(i).split(";");
        QMap<int,QString> dataMap;
        for (int j = 0; j < lineContent.length(); j++) {
            dataMap.insert(j,lineContent.at(j));
        }
        map_.insert(i, dataMap);
    }
}
/*
 * This is a custom method that takes in JSON data and converts its content to build out the headers, fileName, and data for the table model
 * As well as write each data input to a file if the exportOnAdd flag is set to true
*/
void SGCSVTableUtils::updateTableFromControlView(QJsonValue data, bool exportOnAdd)
{
    if (!data["cmd"].isUndefined() && cmdName_ != data["cmd"].toString()) {
        cmdName_ = data["cmd"].toString();
        headers_.clear();
        clearBackingModel();
        beginResetModel();
        map_.clear();
        endResetModel();
    } else if(!data["value"].isUndefined() && cmdName_ != data["value"].toString()){
        cmdName_ = data["value"].toString();
        clearBackingModel();
        beginResetModel();
        map_.clear();
        endResetModel();
    }
    QJsonObject payloadObject = data["payload"].toObject();
    if (headers_.length() == 0) {
        headers_ = payloadObject.keys();
        createheaders(headers_);
    }
    insertRows(rowCount(),1,index(rowCount(),0));
    QMap <int, QString> convertedMap;
    foreach(QString key, payloadObject.keys()) {
        QJsonValue val = payloadObject.value(key);
        QString retStr;
        switch (val.type()) {
            case QJsonValue::Array: {
                QJsonDocument doc(val.toArray());
                retStr = doc.toJson(QJsonDocument::Compact);
            }
            break;
            case QJsonValue::Object: {
                QJsonDocument doc(val.toObject());
                retStr = doc.toJson(QJsonDocument::Compact);
            }
            break;
            case QJsonValue::String: {
                retStr = val.toVariant().toString();
            }
            break;
            case QJsonValue::Double: {
                retStr = val.toVariant().toString();
            }
            break;
            case QJsonValue::Bool: {
                retStr = val.toVariant().toString();
            }
            break;
            case QJsonValue::Null: {
                return;
            }
            break;
            case QJsonValue::Undefined: {
                return;
            }
            break;
            default: {
                retStr = val.toVariant().toString();
            }
        }
        convertedMap.insert(headers_.indexOf(key), retStr);
    }
    map_.insert(rowCount(),convertedMap);
    if (exportOnAdd) {
        writeLineToFile(convertedMap);
    }
}
/* This is a custom method that converts a complete table into a .csv file */
void SGCSVTableUtils::writeToPath()
{
    SGUtilsCpp _utils;
    QUrl url = _utils.joinFilePath(folderPath_, cmdName_+".csv");
    QString path = _utils.urlToLocalFile(url);
    _utils.atomicWrite(path, exportModelToCSV());
}

