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
#include <Mock/MockDeviceScanner.h>

class SciMockDeviceModel : public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciMockDeviceModel)

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit SciMockDeviceModel(strata::PlatformManager *platformManager);
    virtual ~SciMockDeviceModel() override;
    void init();

    Q_INVOKABLE QString connectMockDevice(const QString& deviceName, const QByteArray& deviceId);
    Q_INVOKABLE bool disconnectMockDevice(const QByteArray& deviceId);
    Q_INVOKABLE void disconnectAllMockDevices();
    Q_INVOKABLE QString getLatestMockDeviceName() const;
    Q_INVOKABLE QByteArray getMockDeviceId(const QString& deviceName) const;

    enum ModelRole {
        DeviceIdRole = Qt::UserRole + 1,
        DeviceNameRole,
    };

    struct DeviceData {
        QByteArray deviceId_;
        QString deviceName_;
    };

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int count() const;

signals:
    void countChanged();

private slots:
    void handleDeviceDetected(strata::platform::PlatformPtr platform);
    void handleDeviceLost(QByteArray deviceId);

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    void clear();

    QList<DeviceData> platforms_;
    strata::PlatformManager *platformManager_;
    strata::device::scanner::MockDeviceScannerPtr scanner_;
    unsigned latestMockIdx_ = 1;
};
