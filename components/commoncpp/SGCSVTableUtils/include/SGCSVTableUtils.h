#pragma once
#include <QObject>
#include <QStringList>
#include <QMap>
#include <QUrl>
#include <QVariant>
#include <QAbstractTableModel>

class SGCSVTableUtils: public QAbstractTableModel
{
    Q_OBJECT
    Q_PROPERTY(QStringList headers READ headers WRITE setHeaders NOTIFY headersChanged)
    Q_PROPERTY(QString cmdName READ cmdName WRITE setCmdName NOTIFY cmdNameChanged)
public:

    enum CSVTableRole {
        KeyRole = Qt::UserRole + 1,
        ValueRole
    };

    explicit SGCSVTableUtils(QObject *parent = nullptr);
    QStringList headers() const
    {
        return _headers;
    }
    QString cmdName() const
    {
        return _cmdName;
    }
    void setCmdName(QString cmdName)
    {
        if (_cmdName != cmdName)
        {
            _cmdName = cmdName;
            emit cmdNameChanged();
        }
    }
    void setHeaders(QStringList headers)
    {
        if (_headers != headers)
        {
            _headers = headers;
            _map.clear();
            _dataMap.clear();
            createheaders(_headers);
            emit headersChanged();
        }
    }
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    int columnCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QVariant headerData(int section,Qt::Orientation orientation, int role = Qt::DisplayRole) const override;
    bool insertRows(int row, int count, const QModelIndex &parent) override;
    void createheaders(QStringList headers);
    bool checkIfColumnFilledOut(QMap<int,QMap<int,QString>> map, int row);
    Q_INVOKABLE void updateMap(QString name, QVariant data);
    QString exportModelToCSV();
    Q_INVOKABLE void writeToPath(QString folderPath);
signals:
    void headersChanged();
    void cmdNameChanged();
private:
    QMap<int,QMap<int,QString>> _map;
    QMap<int,QString> _dataMap;
    QStringList _headers;
    QString _cmdName;
    int _rows = 0;
};


