#include "BluetoothLowEnergy/BluetoothLowEnergyController.h"

#include "logging/LoggingQtCategories.h"

namespace strata::device {

constexpr std::chrono::seconds BLE_TIMEOUT(60); // connect timer, 60s

BluetoothLowEnergyController::BluetoothLowEnergyController(const QBluetoothDeviceInfo &info, QObject* parent)
    : QObject(parent),
      deleteLater_(false),
      allDiscovered_(false),
      controllerActive_(false),
      openingTimer_(this)
{
    openingTimer_.setInterval(BLE_TIMEOUT);
    openingTimer_.setSingleShot(true);
    connect(&openingTimer_, &QTimer::timeout, this, &BluetoothLowEnergyController::openingTimeoutHandler);

    lowEnergyController_ = QLowEnergyController::createCentral(info, this);

    connect(lowEnergyController_, &QLowEnergyController::discoveryFinished, this, &BluetoothLowEnergyController::discoveryFinishedHandler, Qt::QueuedConnection);
    connect(lowEnergyController_, &QLowEnergyController::connected, this, &BluetoothLowEnergyController::deviceConnectedHandler, Qt::QueuedConnection);
    connect(lowEnergyController_, &QLowEnergyController::disconnected, this, &BluetoothLowEnergyController::deviceDisconnectedHandler, Qt::QueuedConnection);
    connect(lowEnergyController_, (void (QLowEnergyController::*)(QLowEnergyController::Error)) &QLowEnergyController::error,
            this, &BluetoothLowEnergyController::deviceErrorReceivedHandler, Qt::QueuedConnection);
    connect(lowEnergyController_, &QLowEnergyController::stateChanged, this, &BluetoothLowEnergyController::deviceStateChangeHandler, Qt::QueuedConnection);
}

BluetoothLowEnergyController::~BluetoothLowEnergyController()
{
    // all BLE pointers will be erased thanks to to properly set parent
}

void BluetoothLowEnergyController::open()
{
    if(controllerActive_ == true) {
        return;
    }

    controllerActive_ = true;
    openingTimer_.start();

    qCDebug(logCategoryDeviceBLE) << this << "Connecting to BLE device...";
    lowEnergyController_->connectToDevice();
}

void BluetoothLowEnergyController::close()
{
    if(controllerActive_ == false) {
        return;
    }

    qCDebug(logCategoryDeviceBLE) << this << "Closing BLE device...";

    openingTimer_.stop();
    controllerActive_ = false;
    emit disconnected(allDiscovered_ == false);

#ifdef Q_OS_WIN
    // only for windows, leave the connecting running until it finishes
    if ((allDiscovered_ == false) && (lowEnergyController_->state() == QLowEnergyController::DiscoveringState)) {
        deleteLater_ = true;
        return;
    }
#endif

    if (lowEnergyController_->state() != QLowEnergyController::UnconnectedState) {
        lowEnergyController_->disconnectFromDevice(); // attempt gracefull close, will emit finished later
    } else {
        emit finished();   // nothing is open, just flag for deletion immediatelly
    }
}

bool BluetoothLowEnergyController::isConnected() const
{
    return lowEnergyController_->state() == QLowEnergyController::DiscoveredState && allDiscovered_;
}

void BluetoothLowEnergyController::openingTimeoutHandler()
{
    qCDebug(logCategoryDeviceBLE) << this << "Timeout while connecting and/or discovering services";
    close();
}

void BluetoothLowEnergyController::deviceConnectedHandler()
{
    QLowEnergyController *lowEnergyController = qobject_cast<QLowEnergyController*>(QObject::sender());
    if ((lowEnergyController == nullptr) || (lowEnergyController != lowEnergyController_)) {
        return;
    }

    qCDebug(logCategoryDeviceBLE) << this << "Device connected, discovering services...";
    lowEnergyController_->discoverServices();
}

void BluetoothLowEnergyController::deviceDisconnectedHandler()
{
    QLowEnergyController *lowEnergyController = qobject_cast<QLowEnergyController*>(QObject::sender());
    if ((lowEnergyController == nullptr) || (lowEnergyController != lowEnergyController_)) {
        return;
    }

    qCDebug(logCategoryDeviceBLE) << this << "Device disconnected.";

    if(controllerActive_) {
        // this signal came from the device itself
        close();    // lowEnergyController_ will be in UnconnectedState so it is ok to call close
    } else {
        emit finished();
    }
}

void BluetoothLowEnergyController::discoveryFinishedHandler()
{
    QLowEnergyController *lowEnergyController = qobject_cast<QLowEnergyController*>(QObject::sender());
    if ((lowEnergyController == nullptr) || (lowEnergyController != lowEnergyController_)) {
        return;
    }

    qCDebug(logCategoryDeviceBLE) << this << "Service discovery finished, discovering service details...";
    discoverServiceDetails();
}

void BluetoothLowEnergyController::discoverServiceDetails()
{
    QList<QBluetoothUuid> services = lowEnergyController_->services();
    for (const QBluetoothUuid &serviceUuid : services) {
        addDiscoveredService(serviceUuid);
    }
    checkServiceDetailsDiscovery();
}

void BluetoothLowEnergyController::checkServiceDetailsDiscovery()
{
    bool allDiscovered = true;
    for (const auto &service : discoveredServices_) {
        switch (service.second->state()) {
            case QLowEnergyService::InvalidService:
                break;
            case QLowEnergyService::DiscoveryRequired:
                // TODO: decide what to do when discovery fails
                if (deleteLater_ == false) {    // if discovery fails, it returns to DiscoveryRequired, which can loop here
                    qCDebug(logCategoryDeviceBLE) << this << "Discovering details of service " << service.second->serviceUuid() << " ...";
                    service.second->discoverDetails();
                    allDiscovered = false;
                }
                break;
            case QLowEnergyService::DiscoveringServices:
                allDiscovered = false;
                break;
            case QLowEnergyService::ServiceDiscovered:
                break;
            case QLowEnergyService::LocalService:
                break;
        }
    }
    if (allDiscovered && allDiscovered_ == false) {
        if (lowEnergyController_->state() == QLowEnergyController::DiscoveredState) {
            allDiscovered_ = true;
            qCDebug(logCategoryDeviceBLE) << this << "Service details discovery finished";
            for (const auto &service : discoveredServices_) {
                qCDebug(logCategoryDeviceBLE) << this << "Service " << service.second->serviceUuid() << " state " << service.second->state();
            }
            if (deleteLater_ == false) {
                openingTimer_.stop();
                emit connected();
            } else {
                lowEnergyController_->disconnectFromDevice();
            }
        } else {
            qCWarning(logCategoryDeviceBLE) << this << "Service details discovery finished, but the BLE device is not open.";
        }
    }
}

void BluetoothLowEnergyController::deviceErrorReceivedHandler(QLowEnergyController::Error error)
{
    QLowEnergyController *lowEnergyController = qobject_cast<QLowEnergyController*>(QObject::sender());
    if ((lowEnergyController == nullptr) || (lowEnergyController != lowEnergyController_)) {
        return;
    }

    emit deviceError(error, lowEnergyController->errorString());

    if (allDiscovered_ == false) {
        close();
    }
}

void BluetoothLowEnergyController::deviceStateChangeHandler(QLowEnergyController::ControllerState state)
{
    QLowEnergyController *lowEnergyController = qobject_cast<QLowEnergyController*>(QObject::sender());
    if ((lowEnergyController == nullptr) || (lowEnergyController != lowEnergyController_)) {
        return;
    }

    qCDebug(logCategoryDeviceBLE) << this << "Device state changed: " << state;
}

void BluetoothLowEnergyController::descriptorWrittenHandler(const QLowEnergyDescriptor &info, const QByteArray &value)
{
    QByteArray serviceUuid = getSignalSenderServiceUuid();
    if (serviceUuid.isNull()) {
        return;
    }

    emit serviceDescriptorWritten(serviceUuid, info, value);
}

void BluetoothLowEnergyController::characteristicWrittenHandler(const QLowEnergyCharacteristic &info, const QByteArray &value)
{
    QByteArray serviceUuid = getSignalSenderServiceUuid();
    if (serviceUuid.isNull()) {
        return;
    }

    emit serviceCharacteristicWritten(serviceUuid, info, value);
}

void BluetoothLowEnergyController::characteristicReadHandler(const QLowEnergyCharacteristic &info, const QByteArray &value)
{
    QByteArray serviceUuid = getSignalSenderServiceUuid();
    if (serviceUuid.isNull()) {
        return;
    }

    emit serviceCharacteristicRead(serviceUuid, info, value);
}

void BluetoothLowEnergyController::characteristicChangedHandler(const QLowEnergyCharacteristic &info, const QByteArray &value)
{
    QByteArray serviceUuid = getSignalSenderServiceUuid();
    if (serviceUuid.isNull()) {
        return;
    }

    emit serviceCharacteristicChanged(serviceUuid, info, value);
}

void BluetoothLowEnergyController::serviceStateChangedHandler(QLowEnergyService::ServiceState newState)
{
    QLowEnergyService *service = qobject_cast<QLowEnergyService*>(QObject::sender());
    if ((service == nullptr) || (getService(service->serviceUuid()) != service)) {
        return;
    }

    qCDebug(logCategoryDeviceBLE) << this << "Service state changed: " << newState;
    checkServiceDetailsDiscovery();
}

void BluetoothLowEnergyController::serviceErrorHandler(QLowEnergyService::ServiceError error)
{
    QByteArray serviceUuid = getSignalSenderServiceUuid();
    if (serviceUuid.isNull()) {
        return;
    }

    emit serviceError(serviceUuid, error);
}

void BluetoothLowEnergyController::addDiscoveredService(const QBluetoothUuid & serviceUuid)
{
    qCDebug(logCategoryDeviceBLE) << this << "Creating service for UUID " << serviceUuid << " ...";
    if (discoveredServices_.count(serviceUuid) != 0) {
        // It is allowed to have multiple services with the same UUID, so this is a correct situation.
        // If multiple services with the same UUID need to be accessed, it should be done via handles (to be implemented later)
        qCInfo(logCategoryDeviceBLE) << this << "Duplicate service UUID " << serviceUuid << ", ignoring the latter.";
        return;
    }
    QLowEnergyService * service = lowEnergyController_->createServiceObject(serviceUuid, lowEnergyController_); // will be automatically deleted after controller is erased
    if (service == nullptr) {
        qCWarning(logCategoryDeviceBLE) << this << "Invalid service";
        return;
    }
    if (service->serviceUuid() != serviceUuid) {
        // this should never happen, but we rely on this condition later, so let's better check it
        qCWarning(logCategoryDeviceBLE) << this << "Invalid service: inconsistent uuid";
        delete service;
        return;
    }
    discoveredServices_[service->serviceUuid()] = service;

    connect(service, &QLowEnergyService::characteristicWritten, this, &BluetoothLowEnergyController::characteristicWrittenHandler, Qt::QueuedConnection);
    connect(service, &QLowEnergyService::descriptorWritten, this, &BluetoothLowEnergyController::descriptorWrittenHandler, Qt::QueuedConnection);
    connect(service, &QLowEnergyService::characteristicRead, this, &BluetoothLowEnergyController::characteristicReadHandler, Qt::QueuedConnection);
    connect(service, &QLowEnergyService::characteristicChanged, this, &BluetoothLowEnergyController::characteristicChangedHandler, Qt::QueuedConnection);
    connect(service, (void (QLowEnergyService::*)(QLowEnergyService::ServiceError)) &QLowEnergyService::error, this, &BluetoothLowEnergyController::serviceErrorHandler, Qt::QueuedConnection);
    connect(service, &QLowEnergyService::stateChanged, this, &BluetoothLowEnergyController::serviceStateChangedHandler, Qt::QueuedConnection);
}

QLowEnergyService * BluetoothLowEnergyController::getService(const QBluetoothUuid & serviceUuid) const
{
    auto iter = discoveredServices_.find(serviceUuid);
    if (iter == discoveredServices_.end()) {
        return nullptr;
    }
    return iter->second;
}

QByteArray BluetoothLowEnergyController::getSignalSenderServiceUuid() const
{
    QLowEnergyService *service = qobject_cast<QLowEnergyService*>(QObject::sender());
    if ((service == nullptr) || (getService(service->serviceUuid()) != service)) {
        return QByteArray();
    }

    return service->serviceUuid().toByteArray(QBluetoothUuid::WithoutBraces);
}

}  // namespace
