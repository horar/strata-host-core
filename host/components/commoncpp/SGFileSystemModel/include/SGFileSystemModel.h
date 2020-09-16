#pragma once

#include <QTreeView>
#include <QFileSystemModel>
#include <QUrl>
#include <QDateTime>
#include <QFileInfo>

class SGFileSystemModel : public QFileSystemModel
{
    Q_OBJECT
    Q_PROPERTY(QString rootDirectory READ rootDirectory WRITE setRootDirectory NOTIFY rootDirectoryChanged)
    Q_PROPERTY(QModelIndex rootIndex READ rootIndex NOTIFY rootIndexChanged)
private:
    QString rootDirectory_;
    QModelIndex rootIndex_;

public:
    explicit SGFileSystemModel(QObject *parent = nullptr);
    virtual ~SGFileSystemModel();

    enum Roles {
        FileSizeRole = Qt::UserRole + 4,
        FileInfoRole = Qt::UserRole + 5,
        FileTypeRole = Qt::UserRole + 6
    };
    Q_ENUM(Roles)

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    QString rootDirectory() const;
    QModelIndex rootIndex() const;

    void setRootDirectory(QString root);

signals:
    void rootDirectoryChanged();
    void rootIndexChanged();
};
