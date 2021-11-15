/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once
#include <QAbstractListModel>

#include <PlatformManager.h>
#include <BluetoothLowEnergy/BluetoothLowEnergyScanner.h>

using strata::device::scanner::BluetoothLowEnergyScanner;

struct SciBleDeviceModelItem {
    QByteArray deviceId;
    QString name;
    QString address;
    QString errorString;
    qint16 rssi;
    QVector<quint16> manufacturerIds;
    bool isStrata;
    bool isConnected;
    bool connectionInProgress;
};

class SciBleDeviceModel : public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciBleDeviceModel)

    Q_PROPERTY(bool inDiscoveryMode READ inDiscoveryMode NOTIFY inDiscoveryModeChanged)
    Q_PROPERTY(bool isConnecting READ isConnecting NOTIFY isConnectingChanged)
    Q_PROPERTY(QString lastDiscoveryError READ lastDiscoveryError NOTIFY lastDiscoveryErrorChanged)

public:

    SciBleDeviceModel(strata::PlatformManager *platformManager, QObject *parent = nullptr);
    virtual ~SciBleDeviceModel() override;

    enum ModelRole {
        NameRole = Qt::UserRole + 1,
        AddressRole,
        ErrorStringRole,
        RssiRole,
        IsStrataRole,
        IsConnectedRole,
        ConnectionInProgressRole
    };

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    void init();

    Q_INVOKABLE QString bleSupportError() const;
    Q_INVOKABLE void startDiscovery();
    Q_INVOKABLE void tryConnectDevice(int index);
    Q_INVOKABLE void tryDisconnectDevice(int index);
    Q_INVOKABLE QVariantMap get(int row);

    bool inDiscoveryMode() const;
    bool isConnecting() const;
    QString lastDiscoveryError() const;

signals:
    void inDiscoveryModeChanged();
    void isConnectingChanged();
    void lastDiscoveryErrorChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private slots:
    void discoveryFinishedHandler(
            BluetoothLowEnergyScanner::DiscoveryFinishStatus status,
            QString errorString);
    void platformOpenedHandler(const QByteArray deviceId);
    void platformRemovedHandler(const QByteArray deviceId, const QString errorString);

private:
    void populateModel();
    void clearModel();
    void setModelRoles();
    int findDeviceIndex(const QString &deviceId);
    void setPropertyAt(int row, const QVariant &value, int role);
    void setInDiscoveryMode(bool inDiscoveryMode);
    void setLastDiscoveryError(QString lastDiscoveryError);
    bool addConnectingDevice(const QByteArray &deviceId);
    bool removeConnectingDevice(const QByteArray &deviceId);

    strata::PlatformManager *platformManager_ = nullptr;
    strata::device::scanner::BluetoothLowEnergyScannerPtr scanner_;
    QList<SciBleDeviceModelItem> data_;
    QHash<int, QByteArray> roleByEnumHash_;
    QSet<QByteArray> requestedIds_;
    QSet<QByteArray> connectedDeviceIds_;
    bool inDiscoveryMode_ = false;
    QString lastDiscoveryError_;
};
