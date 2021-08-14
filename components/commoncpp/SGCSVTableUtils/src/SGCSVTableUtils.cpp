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

void SGCSVTableUtils::updateMap(QString name, QVariant data)
{
    if (checkIfColumnFilledOut(_map,rowCount()))
    {
        insertRows(rowCount(),1,index(rowCount(),0));
    }
    _dataMap.insert(_headers.indexOf(name), data.toString());
    _map.insert(rowCount(), _dataMap);
}

bool SGCSVTableUtils::insertRows(int row, int count, const QModelIndex &parent)
{
    beginInsertRows(parent,row, row + count - 1);
    _rows += count;
    endInsertRows();

    return true;
}

bool SGCSVTableUtils::checkIfColumnFilledOut(QMap<int,QMap<int, QString>> map, int row)
{
    if (map.take(row).keys().length() == _headers.length())
    {
        _dataMap.clear();
        return true;
    }

    return false;
}

void SGCSVTableUtils::writeToPath(QString folderPath)
{
    SGUtilsCpp _utils;
    QUrl url = _utils.joinFilePath(folderPath, _cmdName+".csv");
    QString path = _utils.urlToLocalFile(url);
    _utils.atomicWrite(path, exportModelToCSV());
}

void SGCSVTableUtils::importTableFromFile(QString folderPath)
{
    SGUtilsCpp _utils;
    QStringList fileContent = _utils.readTextFileContent(folderPath).split("\n");
    for (int i = 0; i < fileContent.length(); i++) {
        QStringList lineContent = fileContent.at(i).split(";");
        for (int j = 0; j < lineContent.length(); j++) {
            _dataMap.insert(j,lineContent.at(j));
        }
        _map.insert(i, _dataMap);
    }
}
