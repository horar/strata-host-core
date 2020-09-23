#pragma once

#include <QAbstractListModel>
#include <QString>
#include <QVariant>
#include <QHash>
#include <QSet>
#include <QUrl>

class SGFileTabItem
{
public:
    SGFileTabItem(const QString &filename, const QUrl &filepath, const QString &filetype, const int id);

    QString filename() const;
    QUrl filepath() const;
    QString filetype() const;

    int id() const;
    bool setFilename(const QString &filename);
    bool setFilepath(const QUrl &filepath);
    bool setFiletype(const QString &filetype);
private:
    int id_;
    QString filename_;
    QUrl filepath_;
    QString filetype_;
};

class SGFileTabModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)
    Q_PROPERTY(int currentId READ currentId WRITE setCurrentId NOTIFY currentIndexChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
public:
    explicit SGFileTabModel(QObject *parent = nullptr);
    ~SGFileTabModel();

    enum RoleNames {
        FilenameRole = Qt::UserRole + 1,
        FilepathRole = Qt::UserRole + 2,
        FiletypeRole = Qt::UserRole + 3,
        IdRole = Qt::UserRole + 4
    };

    // OVERRIDES
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    // CUSTOM FUNCTIONS
    Q_INVOKABLE bool addTab(const QString &filename, const QUrl &filepath, const QString &filetype, const int id);
    Q_INVOKABLE bool closeTab(const int id);
    Q_INVOKABLE bool closeTabAt(const int index);
    Q_INVOKABLE bool hasTab(const int id) const;
    Q_INVOKABLE void clear(bool emitSignals = true);

    int count() const;
    int currentIndex() const;
    int currentId() const;
    void setCurrentIndex(const int index);
    void setCurrentId(const int id);

signals:
    void currentIndexChanged();
    void countChanged();

private:
    QList<SGFileTabItem*> data_;
    int currentIndex_;
    int currentId_;
    QSet<int> tabIds_;
};

