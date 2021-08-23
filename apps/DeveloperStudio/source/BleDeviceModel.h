#pragma once

#include <PlatformInterface/core/CoreInterface.h>
#include <QAbstractListModel>
#include <QStringListModel>

struct BleDeviceModelItem {
    QString deviceId;
    QString name;
    QString address;
    int rssi = 0;
    bool isStrata = false;
    bool isConnected = false;
    bool connectionInProgress = false;
};

class BleDeviceModel : public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(BleDeviceModel)

    Q_PROPERTY(bool inScanMode READ inScanMode NOTIFY inScanModeChanged)
    Q_PROPERTY(QString lastScanError READ lastScanError NOTIFY lastScanErrorChanged)

public:
    BleDeviceModel(CoreInterface *coreInterface, QObject *parent = nullptr);
    virtual ~BleDeviceModel() override;

    enum ModelRole {
        NameRole = Qt::UserRole + 1,
        AddressRole,
        RssiRole,
        IsStrataRole,
        IsConnectedRole,
        ConnectionInProgressRole,
    };

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    Q_INVOKABLE bool bleSupported() const;
    Q_INVOKABLE void startScan();
    Q_INVOKABLE void tryConnect(int row);
    Q_INVOKABLE void tryDisconnect(int row);
    Q_INVOKABLE QVariantMap get(int row);

    bool inScanMode() const;
    QString lastScanError() const;

signals:
    void inScanModeChanged();
    void lastScanErrorChanged();

    void tryConnectFinished(QString errorString);
    void tryDisconnectFinished(QString errorString);

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private slots:
    void bluetoothScanReplyHandler(QJsonObject payload);
    void connectReplyHandler(QJsonObject payload);
    void disconnectReplyHandler(QJsonObject payload);
    void updateDeviceConnection(QJsonObject payload);

private:
    void setModelRoles();
    void clear();
    void populateModel(const QJsonObject &payload);
    int findDeviceIndex(const QString &deviceId);
    void setPropertyAt(int row, const QVariant &value, int role);
    void setInScanMode(bool inScanMode);
    void setLastScanError(QString lastScanError);

    CoreInterface *coreInterface_;
    QList<BleDeviceModelItem> data_;
    QHash<int, QByteArray> roleByEnumHash_;
    QSet<QString> requestedIds_;
    QSet<QString> connectedDeviceIds_;
    bool inScanMode_ = false;
    QString lastScanError_;
};
