#ifndef VERSIONED_LIST_MODEL_H
#define VERSIONED_LIST_MODEL_H

#include <QAbstractListModel>
#include <QJsonArray>
#include <PlatformInterface/core/CoreInterface.h>
#include <QUrl>
#include <QList>

struct VersionedItem {
    VersionedItem(
            const QString &uri,
            const QString &md5,
            const QString &name,
            const QString &timestamp,
            const QString &version,
            const QString &filepath = "")
    {
        this->uri = uri;
        this->md5 = md5;
        this->name = name;
        this->timestamp = timestamp;
        this->version = version;
        this->filepath = filepath;
        this->installed = !filepath.isEmpty();
    }

    QString uri;
    QString md5;
    QString name;
    QString timestamp;
    QString version;
    QString filepath;
    bool installed;
};

class VersionedListModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(VersionedListModel)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    VersionedListModel(QObject *parent = nullptr);
    virtual ~VersionedListModel() override;

    Q_INVOKABLE void setInstalled(int index, bool installed);
    Q_INVOKABLE void setFilepath(int index, QString path);
    Q_INVOKABLE QString version(int index);
    Q_INVOKABLE QString uri(int index);
    Q_INVOKABLE QString md5(int index);
    Q_INVOKABLE QString name(int index);
    Q_INVOKABLE QString timestamp(int index);
    Q_INVOKABLE QString filepath(int index);
    Q_INVOKABLE bool installed(int index);
    Q_INVOKABLE int getLatestVersion();
    Q_INVOKABLE int getInstalledVersion();

    enum {
        UriRole = Qt::UserRole,
        VersionRole,
        NameRole,
        TimestampRole,
        Md5Role,
        InstalledRole,
        FilepathRole
    };

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int count() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    void populateModel(const QList<VersionedItem*> &list);
    void clear(bool emitSignals=true);

signals:
    void countChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    QList<VersionedItem*>data_;

    /**
     * @brief isVersionGreater Checks to see if compareVersion is greater than mainVersion
     * @param mainVersion The version to check against
     * @param compareVersion The version to compare mainVersion to
     * @return True if compareVersion > mainVersion else false
     */
    bool isVersionGreater(const QString &mainVersion, const QString &compareVersion);
};


#endif //VERSIONED_LIST_MODEL_H
