#pragma once

#include <QAbstractListModel>
#include <PlatformManager.h>

class SciMockDeviceModel : public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciMockDeviceModel)

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit SciMockDeviceModel(strata::PlatformManager *platformManager);
    virtual ~SciMockDeviceModel() override;
    void init();

    Q_INVOKABLE bool connectMockDevice(QString deviceName, QByteArray deviceId);
    Q_INVOKABLE bool disconnectMockDevice(QByteArray deviceId);
    Q_INVOKABLE QString getLatestMockDeviceName() const;
    Q_INVOKABLE QByteArray getMockDeviceId(QString deviceName) const;

    enum ModelRole {
        DeviceIdRole = Qt::UserRole + 1,
        DeviceNameRole,
        OpenEnabledRole,
        LegacyModeRole,
        AutoResponseRole,
        MockCommandRole,
        MockResponseRole
    };

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
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
    QList<strata::platform::PlatformPtr> platforms_;
    strata::PlatformManager *platformManager_ = nullptr;
    strata::device::scanner::DeviceScannerPtr scanner_;
    unsigned latestMockIdx_ = 1;
};
