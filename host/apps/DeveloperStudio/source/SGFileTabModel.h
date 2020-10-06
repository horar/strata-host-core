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
    SGFileTabItem(const QString &filename, const QUrl &filepath, const QString &filetype, const QString id);

    QString filename() const;
    QUrl filepath() const;
    QString filetype() const;
    bool unsavedChanges() const;

    QString id() const;
    bool setFilename(const QString &filename);
    bool setFilepath(const QUrl &filepath);
    bool setFiletype(const QString &filetype);
    bool setUnsavedChanges(const bool &unsaved);
private:
    QString id_;
    QString filename_;
    QUrl filepath_;
    QString filetype_;
    bool unsavedChanges_;
};

class SGFileTabModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)
    Q_PROPERTY(QString currentId READ currentId WRITE setCurrentId NOTIFY currentIndexChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
public:
    explicit SGFileTabModel(QObject *parent = nullptr);
    ~SGFileTabModel();

    enum RoleNames {
        FilenameRole = Qt::UserRole + 1,
        FilepathRole = Qt::UserRole + 2,
        FiletypeRole = Qt::UserRole + 3,
        IdRole = Qt::UserRole + 4,
        UnsavedChangesRole = Qt::UserRole + 5
    };

    // OVERRIDES
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    // CUSTOM FUNCTIONS
    Q_INVOKABLE bool addTab(const QString &filename, const QUrl &filepath, const QString &filetype, const QString &id);
    Q_INVOKABLE bool closeTab(const QString &id);
    Q_INVOKABLE bool closeTabAt(const int index);
    Q_INVOKABLE void closeAll();
    Q_INVOKABLE void saveFileAt(const int index);
    Q_INVOKABLE void saveAll();
    Q_INVOKABLE bool hasTab(const QString &id) const;
    Q_INVOKABLE void clear(bool emitSignals = true);
    Q_INVOKABLE int getUnsavedCount();

    int count() const;
    int currentIndex() const;
    QString currentId() const;
    void setCurrentIndex(const int index);
    void setCurrentId(const QString &id);

signals:
    void currentIndexChanged();
    void countChanged();
    void saveRequested(const int index);
    void saveAllRequested();

private:
    QList<SGFileTabItem*> data_;
    int currentIndex_;
    QString currentId_;
    QSet<QString> tabIds_;
};

