#include "BluetoothLowEnergy/BluetoothLowEnergyScanner.h"
#include "logging/LoggingQtCategories.h"

#include <QBluetoothAddress>
#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceInfo>
#include <QBluetoothUuid>
#include <QDebug>

namespace strata::device::scanner {

BluetoothLowEnergyScanner::BluetoothLowEnergyScanner()
    : DeviceScanner(Device::Type::BLEDevice)
{
}

BluetoothLowEnergyScanner::~BluetoothLowEnergyScanner()
{
}

void BluetoothLowEnergyScanner::init()
{
}

void BluetoothLowEnergyScanner::deinit()
{
}

void BluetoothLowEnergyScanner::startDiscovery()
{
    if (discoveryAgent_ != nullptr) {
        if (discoveryAgent_->isActive()) {
            qCDebug(logCategoryDeviceScanner) << "device discovery is already in progress";
            return;
        } else {
            discoveryAgent_->disconnect();
            discoveryAgent_->deleteLater();
        }
    }

    createDiscoveryAgent();
    if (discoveryAgent_ == nullptr) {
        qCCritical(logCategoryDeviceScanner) << "discovery agent not created";

        //make sure signal is emitted after this slot is executed
        QTimer::singleShot(1, this, [this](){
            emit discoveryFinished(DiscoveryFinishStatus::DiscoveryError, "Discovery agent could not be created.");
        });

        return;
    }

    qCDebug(logCategoryDeviceScanner)
            << "device discovery is about to start"
            << "(duration" << discoveryAgent_->lowEnergyDiscoveryTimeout() << "ms)";

    discoveryAgent_->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);
    discoveredDevices_.clear();
}

void BluetoothLowEnergyScanner::stopDiscovery()
{
    if (discoveryAgent_ == nullptr) {
        return;
    }

    qCDebug(logCategoryDeviceScanner) << "device discovery is about to be cancelled";
    discoveryAgent_->stop();
}

const QList<BlootoothLowEnergyInfo> BluetoothLowEnergyScanner::discoveredDevices()
{
    return discoveredDevices_;
}

void BluetoothLowEnergyScanner::tryConnectDevice(const QString &address)
{
    //TODO if we are in the middle of scannig, we should wait until it finishes

    if (discoveryAgent_ == nullptr) {
        return;
    }

    qCDebug(logCategoryDeviceScanner()) << address;

    const QList<QBluetoothDeviceInfo> infoList = discoveryAgent_->discoveredDevices();
    for (const auto &info : infoList) {
        QString infoAddress = getDeviceAddress(info);
        if (infoAddress == address) {
            DevicePtr device = std::make_shared<BluetoothLowEnergyDevice>(info);

            connect(device.get(), &Device::deviceError,
                    this, &BluetoothLowEnergyScanner::deviceErrorHandler);

            platform::PlatformPtr platform = std::make_shared<platform::Platform>(device);

            emit deviceDetected(platform);
        }
    }
}

void BluetoothLowEnergyScanner::discoveryFinishedHandler()
{
    const QList<QBluetoothDeviceInfo> infoList = discoveryAgent_->discoveredDevices();

    qCDebug(logCategoryDeviceScanner()) << "discovered devices:" << infoList.length();

    qCDebug(logCategoryDeviceScanner) << "eligible devices:";
    for (const auto &info : infoList) {
        if (isEligible(info)) {
            qCDebug(logCategoryDeviceScanner) << "name" << info.name();
            qCDebug(logCategoryDeviceScanner) << "address" << info.address();
            qCDebug(logCategoryDeviceScanner) << "deviceUuid" << info.deviceUuid().toString(QBluetoothUuid::WithoutBraces);
            qCDebug(logCategoryDeviceScanner) << "manufacturerIds" << info.manufacturerIds();
            qCDebug(logCategoryDeviceScanner) << "";

            BlootoothLowEnergyInfo infoItem;
            infoItem.name = info.name();

            infoItem.address = getDeviceAddress(info);
            infoItem.manufacturerIds = info.manufacturerIds();

            discoveredDevices_.append(infoItem);
        }
    }

    emit discoveryFinished(DiscoveryFinishStatus::Finished, "");
}

void BluetoothLowEnergyScanner::discoveryCancelledHandler()
{
    qCDebug(logCategoryDeviceScanner()) << "device discovery cancelled";

    emit discoveryFinished(DiscoveryFinishStatus::Cancelled, "");
}

void BluetoothLowEnergyScanner::discoveryErrorHandler(QBluetoothDeviceDiscoveryAgent::Error error)
{
    qCWarning(logCategoryDeviceScanner()) << error << discoveryAgent_->errorString();

    emit discoveryFinished(DiscoveryFinishStatus::DiscoveryError, discoveryAgent_->errorString());
}

void BluetoothLowEnergyScanner::deviceErrorHandler(Device::ErrorCode error, QString errorString)
{
    Q_UNUSED(errorString)

    if (error == Device::ErrorCode::DeviceDisconnected) {
        Device *device = qobject_cast<Device*>(QObject::sender());
        if (device == nullptr) {
            qCWarning(logCategoryDeviceScanner) << "cannot cast sender to device object";
            return;
        }

        //loss is reported after error is processed in Platform
        QByteArray deviceId = device->deviceId();
        QTimer::singleShot(1, this, [this, deviceId](){
            qCDebug(logCategoryDeviceScanner) << "device loss is about to be reported for" << deviceId;
            emit deviceLost(deviceId);
        });
    }
}

bool BluetoothLowEnergyScanner::isEligible(const QBluetoothDeviceInfo &info) const
{
    if ((info.coreConfigurations() & QBluetoothDeviceInfo::LowEnergyCoreConfiguration) == false) {
        return false;
    }

//    const QVector<quint16> manufacturerIds = info.manufacturerIds();
//    for (const auto &id : manufacturerIds) {
//        if (eligibleIds_.indexOf(id) >= 0) {
//            return true;
//        }
//    }

//    return false;

    return true;
}

QString BluetoothLowEnergyScanner::getDeviceAddress(const QBluetoothDeviceInfo &info) const
{
    QString address;

#ifdef Q_OS_MACOS
    address = info.deviceUuid().toString(QBluetoothUuid::WithoutBraces);
#else
    info.address = info.address().toString();
#endif

    return address;
}

void BluetoothLowEnergyScanner::createDiscoveryAgent()
{
    discoveryAgent_ = new QBluetoothDeviceDiscoveryAgent(this);
    if (discoveryAgent_ == nullptr) {
        return;
    }

    discoveryAgent_->setLowEnergyDiscoveryTimeout(discoveryTimeout_.count());

    connect(discoveryAgent_, &QBluetoothDeviceDiscoveryAgent::finished,
            this, &BluetoothLowEnergyScanner::discoveryFinishedHandler);

    connect(discoveryAgent_, &QBluetoothDeviceDiscoveryAgent::canceled,
            this, &BluetoothLowEnergyScanner::discoveryCancelledHandler);

    connect(discoveryAgent_, QOverload<QBluetoothDeviceDiscoveryAgent::Error>::of(&QBluetoothDeviceDiscoveryAgent::error),
            this, &BluetoothLowEnergyScanner::discoveryErrorHandler);
}

}  // namespace
