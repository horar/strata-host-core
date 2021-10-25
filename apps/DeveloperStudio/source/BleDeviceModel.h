/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <PlatformInterface/core/CoreInterface.h>
#include <StrataRPC/StrataClient.h>

#include <QAbstractListModel>
#include <QStringListModel>
#include <QSet>

struct BleDeviceModelItem {
    QString deviceId;
    QString name;
    QString address;
    QString errorString;
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
    Q_PROPERTY(bool isConnecting READ isConnecting NOTIFY isConnectingChanged)
    Q_PROPERTY(QString lastScanError READ lastScanError NOTIFY lastScanErrorChanged)

public:
    BleDeviceModel(strata::strataRPC::StrataClient *strataClient,
                   CoreInterface *coreInterface, QObject *parent = nullptr);
    virtual ~BleDeviceModel() override;

    enum ModelRole {
        NameRole = Qt::UserRole + 1,
        AddressRole,
        ErrorStringRole,
        RssiRole,
        IsStrataRole,
        IsConnectedRole,
        ConnectionInProgressRole,
    };

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    Q_INVOKABLE QString bleSupportError() const;
    Q_INVOKABLE void startScan();
    Q_INVOKABLE void tryConnect(int row);
    Q_INVOKABLE void tryDisconnect(int row);
    Q_INVOKABLE QVariantMap get(int row);

    bool inScanMode() const;
    bool isConnecting() const;
    QString lastScanError() const;

signals:
    void inScanModeChanged();
    void isConnectingChanged();
    void lastScanErrorChanged();

    void tryConnectFinished(QString errorString);
    void tryDisconnectFinished(QString errorString);

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private slots:
    void bluetoothScanReplyHandler(const QJsonObject &payload);
    void bluetoothScanErrorReplyHandler(const QJsonObject &payload);
    void bluetoothScanFinishedHandler(const QJsonObject &payload);
    void connectReplyHandler(const QJsonObject &payload);
    void disconnectReplyHandler(const QJsonObject &payload);
    void updateDeviceConnection(const QJsonObject &payload);

private:
    void setModelRoles();
    void clear();
    void populateModel(const QJsonObject &payload);
    int findDeviceIndex(const QString &deviceId);
    void setPropertyAt(int row, const QVariant &value, int role);
    void setInScanMode(bool inScanMode);
    void setLastScanError(QString lastScanError);
    bool addConnectingDevice(const QString &deviceId);
    bool removeConnectingDevice(const QString &deviceId);

    strata::strataRPC::StrataClient *strataClient_;
    CoreInterface *coreInterface_;
    QList<BleDeviceModelItem> data_;
    QHash<int, QByteArray> roleByEnumHash_;
    QSet<QString> requestedIds_;
    QSet<QString> connectedDeviceIds_;
    bool inScanMode_ = false;
    QString lastScanError_;
};
