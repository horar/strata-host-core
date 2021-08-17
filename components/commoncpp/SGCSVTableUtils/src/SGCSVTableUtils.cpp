#include "SGCSVTableUtils.h"
#include "../SGUtilsCpp/include/SGUtilsCpp.h"
#include "QDebug"

SGCSVTableUtils::SGCSVTableUtils(QObject *parent): QAbstractTableModel(parent)
{
}

QString SGCSVTableUtils::exportModelToCSV()
{
    QString textData;
    int rows = rowCount();
    int columns = columnCount();

    for (int i = 0; i < rows; i++)
    {
        for (int j = 0; j < columns; j++)
        {
            textData += data(index(i,j),Qt::DisplayRole).toString()+";";
        }
        textData += "\n";
    }

    return textData;
}

int SGCSVTableUtils::rowCount(const QModelIndex &parent) const
{
    return _rows;
}

int SGCSVTableUtils::columnCount(const QModelIndex &parent) const
{
    return _headers.length();
}

QVariant SGCSVTableUtils::data(const QModelIndex &index, int role) const
{
    if (_map.isEmpty()) return  QVariant();

    if (index.column() < 0 || index.column() > columnCount() || index.row() < 0 || index.row() > rowCount() || role != Qt::DisplayRole)
    {
        return QString();
    }
    return _map.value(index.row()).value(index.column());
}

QVariant SGCSVTableUtils::headerData(int section, Qt::Orientation orientation, int role) const
{
    if (role != Qt::DisplayRole || orientation != Qt::Horizontal) {
        return QVariant();
    }

    return _map.value(0).value(section);
}

void SGCSVTableUtils::createheaders(QStringList headers)
{
    QMap<int,QString> headerMap;
    foreach(QString header, headers)
    {
        headerMap.insert(headers.indexOf(header), header);
    }
    _map.insert(rowCount(), headerMap);
}

void SGCSVTableUtils::updateTableFromControlView(QJsonValue data, bool exportOnAdd)
{

    QMap<QString, QVariant> dataMap = data.toVariant().toMap();
    insertRows(rowCount(),1,index(rowCount(),0));
    QMap <int, QString> convertedMap;
    for (int i = 0; i < dataMap.count(); i++) {
        convertedMap.insert(i, dataMap.value(_headers.at(i)).toString());
    }
    _map.insert(rowCount(),convertedMap);
    if (exportOnAdd) {
        writeLineToFile(convertedMap);
    }
}

bool SGCSVTableUtils::insertRows(int row, int count, const QModelIndex &parent)
{
    beginInsertRows(parent,row, row + count - 1);
    _rows += count;
    endInsertRows();

    return true;
}

void SGCSVTableUtils::writeToPath()
{
    SGUtilsCpp _utils;
    QUrl url = _utils.joinFilePath(_folderPath, _cmdName+".csv");
    QString path = _utils.urlToLocalFile(url);
    _utils.atomicWrite(path, exportModelToCSV());
}

void SGCSVTableUtils::importTableFromFile(QString folderPath)
{
    clearBackingModel();
    beginResetModel();
    _map.clear();
    endResetModel();
    SGUtilsCpp _utils;
    QStringList fileContent = _utils.readTextFileContent(folderPath).split("\n");
    for (int i = 0; i < fileContent.length(); i++) {
        QStringList lineContent = fileContent.at(i).split(";");
        QMap<int,QString> dataMap;
        for (int j = 0; j < lineContent.length(); j++) {
            dataMap.insert(j,lineContent.at(j));
        }
        _map.insert(i, dataMap);
    }
}

void SGCSVTableUtils::writeLineToFile(QMap<int, QString> data) {
    QString textDataRow;
    for (int i = 0; i < data.count(); i++) {
        textDataRow += data.value(i)+";";
    }
    SGUtilsCpp _utils;
    QUrl url = _utils.joinFilePath(_folderPath, _cmdName+".csv");
    QString path = _utils.urlToLocalFile(url);
    QFile file(path);
    if (file.open(QFile::Append | QFile::Text)) {
        QTextStream out(&file);
        if (file.size() == 0) {
            QString textHeaderRow;
            for (int i = 0; i < _headers.length(); i++) {
                textHeaderRow += _headers.at(i)+";";
            }
            out << textHeaderRow;
            out << endl;
        }
        out << textDataRow;
        out << endl;
    }
    file.close();
}
