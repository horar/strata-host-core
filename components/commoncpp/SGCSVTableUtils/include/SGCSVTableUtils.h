#pragma once
#include <QObject>
#include <QStringList>
#include <QMap>
#include <QUrl>
#include <QVariant>
#include <QAbstractTableModel>
#include <QJsonValue>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QStandardPaths>
#include <QDateTime>
#include <QDir>

class SGCSVTableUtils: public QAbstractTableModel
{
    Q_OBJECT
public:
    explicit SGCSVTableUtils(QObject *parent = nullptr);
    virtual ~SGCSVTableUtils();

    int columnCount(const QModelIndex& parent = QModelIndex()) const override;
    void createheaders(QStringList headers);
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QString exportModelToCSV();
    QString folderPath() const;
    QVariant headerData(int section,Qt::Orientation orientation, int role = Qt::DisplayRole) const override;
    bool insertRows(int row, int count, const QModelIndex &parent) override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    void setFolderPath(QString folderPath);
    void setOutputFolderLocation();
    void writeLineToFile(QMap<int, QString> data);

    Q_INVOKABLE int getHeadersCount() const;
    Q_INVOKABLE void importTableFromFile(QString folderPath);
    Q_INVOKABLE void overrideFolderPath(QString folderPath);
    Q_INVOKABLE void updateTableFromControlView(QJsonValue data, bool exportOnAdd);
    Q_INVOKABLE void writeToPath();
signals:
    void clearBackingModel();
private slots:
    void clearAll() {
        cmdName_ = "";
        headers_.clear();
        map_.clear();
        rows_ = 0;
    }

private:
    QString cmdName_;
    QString folderPath_;
    QStringList headers_;
    QMap<int,QMap<int,QString>> map_;
    int rows_ = 0;
    QString dateTime_;
};


