#pragma once
#include <QObject>
#include <QStringList>
#include <QMap>
#include <QUrl>
#include <QVariant>
#include <QAbstractTableModel>
#include <QJsonValue>

class SGCSVTableUtils: public QAbstractTableModel
{
    Q_OBJECT
    Q_PROPERTY(QStringList headers READ headers WRITE setHeaders NOTIFY headersChanged)
    Q_PROPERTY(QString cmdName READ cmdName WRITE setCmdName NOTIFY cmdNameChanged)
    Q_PROPERTY(QString folderPath READ folderPath WRITE setFolderPath NOTIFY folderPathChanged)
public:

    enum CSVTableRole {
        KeyRole = Qt::UserRole + 1,
        ValueRole
    };

    explicit SGCSVTableUtils(QObject *parent = nullptr);
    QString folderPath() const
    {
        return _folderPath;
    }
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
    void setFolderPath(QString folderPath)
    {
        if (_folderPath != folderPath) {
            _folderPath = folderPath;
            emit folderPathChanged();
        }
    }
    void setHeaders(QStringList headers)
    {
        if (_headers != headers)
        {
            _headers = headers;
            _map.clear();
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
    QString exportModelToCSV();
    Q_INVOKABLE void updateTableFromControlView(QJsonValue data, bool exportOnAdd);
    Q_INVOKABLE void writeToPath();
    Q_INVOKABLE void importTableFromFile(QString folderPath);
    void writeLineToFile(QMap<int, QString> data);
signals:
    void headersChanged();
    void cmdNameChanged();
    void folderPathChanged();
    void clearBackingModel();

private:
    QMap<int,QMap<int,QString>> _map;
    QStringList _headers;
    QString _cmdName;
    QString _folderPath;
    int _rows = 0;
};


