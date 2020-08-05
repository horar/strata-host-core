#ifndef FIRMWARE_LIST_MODEL_H
#define FIRMWARE_LIST_MODEL_H

#include <QAbstractListModel>
#include <QJsonArray>
#include <PlatformInterface/core/CoreInterface.h>
#include <QUrl>
#include <QList>

struct FirmwareItem {

    FirmwareItem(
            const QString &uri,
            const QString &md5,
            const QString &name,
            const QString &timestamp,
            const QString &version)
    {
        this->uri = uri;
        this->md5 = md5;
        this->name = name;
        this->timestamp = timestamp;
        this->version = version;
        installed = false;
    }

    QString uri;
    QString md5;
    QString name;
    QString timestamp;
    QString version;
    bool installed;
};

class FirmwareListModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(FirmwareListModel)

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    FirmwareListModel(QObject *parent = nullptr);
    virtual ~FirmwareListModel() override;

    Q_INVOKABLE QString version(int index);
    Q_INVOKABLE void setInstalled(int index, bool installed);

    enum {
        UriRole = Qt::UserRole,
        VersionRole,
        NameRole,
        TimestampRole,
        Md5Role,
        InstalledRole
    };

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int count() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    void populateModel(const QList<FirmwareItem*> &list);
    void clear(bool emitSignals=true);

signals:
    void countChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    QList<FirmwareItem*>data_;
};


#endif //FIRMWARE_LIST_MODEL_H
