#pragma once
#include <QAbstractListModel>

#include <PlatformManager.h>
#include <BluetoothLowEnergy/BluetoothLowEnergyScanner.h>

struct SciBleDeviceModelItem {
    QString name;
    QString address;
    QVector<quint16> manufacturerIds;
};

class SciBleDeviceModel : public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciBleDeviceModel)

    Q_PROPERTY(bool inDiscoveryMode READ inDiscoveryMode NOTIFY inDiscoveryModeChanged)

public:

    SciBleDeviceModel(strata::PlatformManager *platformManager, QObject *parent = nullptr);
    virtual ~SciBleDeviceModel() override;

    enum ModelRole {
        NameRole = Qt::UserRole + 1,
        AddressRole,
    };

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    void init();

    Q_INVOKABLE void startDiscovery();
    Q_INVOKABLE void tryConnectDevice(int index);
    Q_INVOKABLE QVariantMap get(int row);

    bool inDiscoveryMode();

signals:
    void inDiscoveryModeChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private slots:
    void populateModel();

private:
    void setModelRoles();
    void setInDiscoveryMode(bool inDiscoveryMode);

    strata::PlatformManager *platformManager_ = nullptr;
    strata::device::scanner::BluetoothLowEnergyScannerPtr scanner_;
    QList<SciBleDeviceModelItem> data_;
    QHash<int, QByteArray> roleByEnumHash_;
    bool inDiscoveryMode_ = false;
};
