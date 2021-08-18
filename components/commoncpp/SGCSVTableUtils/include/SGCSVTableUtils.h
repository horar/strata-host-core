#pragma once
#include <QObject>
#include <QStringList>
#include <QMap>
#include <QUrl>
#include <QVariant>
#include <QAbstractTableModel>
#include <QJsonValue>
#include <QJsonObject>

class SGCSVTableUtils: public QAbstractTableModel
{
    Q_OBJECT
    Q_PROPERTY(QString folderPath READ folderPath WRITE setFolderPath NOTIFY folderPathChanged)
public:
    explicit SGCSVTableUtils(QObject *parent = nullptr);

    int columnCount(const QModelIndex& parent = QModelIndex()) const override;
    void createheaders(QStringList headers);
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QString exportModelToCSV();
    QString folderPath() const;
    QVariant headerData(int section,Qt::Orientation orientation, int role = Qt::DisplayRole) const override;
    bool insertRows(int row, int count, const QModelIndex &parent) override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    void setFolderPath(QString folderPath);
    void writeLineToFile(QMap<int, QString> data);

    Q_INVOKABLE int getHeadersCount() const;
    Q_INVOKABLE void importTableFromFile(QString folderPath);
    Q_INVOKABLE void updateTableFromControlView(QJsonValue data, bool exportOnAdd);
    Q_INVOKABLE void writeToPath();
signals:
    void clearBackingModel();
    void folderPathChanged();

private:
    QString cmdName_;
    QString folderPath_;
    QStringList headers_;
    QMap<int,QMap<int,QString>> map_;
    int rows_ = 0;
};


