/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
    if((controllerActive_ == true) ||
       (lowEnergyController_->state() != QLowEnergyController::UnconnectedState)) {
        return;
    }

    controllerActive_ = true;
    openingTimer_.start();

    qCDebug(lcDeviceBLE) << this << "Connecting to BLE device...";

    lowEnergyController_->connectToDevice();
}

void BluetoothLowEnergyController::close()
{
    if(controllerActive_ == false) {
        return;
    }

    openingTimer_.stop();
    controllerActive_ = false;

    qCDebug(lcDeviceBLE) << this << "Closing BLE device...";

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

void BluetoothLowEnergyController::disconnect()
{
    emit disconnected(allDiscovered_ == false);

    close();
}

bool BluetoothLowEnergyController::isConnected() const
{
    return lowEnergyController_->state() == QLowEnergyController::DiscoveredState && allDiscovered_;
}

void BluetoothLowEnergyController::openingTimeoutHandler()
{
    qCDebug(lcDeviceBLE) << this << "Timeout while connecting and/or discovering services";
    disconnect();
}

void BluetoothLowEnergyController::deviceConnectedHandler()
{
    QLowEnergyController *lowEnergyController = qobject_cast<QLowEnergyController*>(QObject::sender());
    if ((lowEnergyController == nullptr) || (lowEnergyController != lowEnergyController_)) {
        return;
    }

    qCDebug(lcDeviceBLE) << this << "Device connected, discovering services...";
    lowEnergyController_->discoverServices();
}

void BluetoothLowEnergyController::deviceDisconnectedHandler()
{
    QLowEnergyController *lowEnergyController = qobject_cast<QLowEnergyController*>(QObject::sender());
    if ((lowEnergyController == nullptr) || (lowEnergyController != lowEnergyController_)) {
        return;
    }

    qCDebug(lcDeviceBLE) << this << "Device disconnected.";

    if(controllerActive_) {
        // this signal came from the device itself
        disconnect();   // lowEnergyController_ will be in UnconnectedState
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

    qCDebug(lcDeviceBLE) << this << "Service discovery finished, discovering service details...";
    discoverServiceDetails();
}

void BluetoothLowEnergyController::discoverServiceDetails()
{
    QList<QBluetoothUuid> services = lowEnergyController_->services();
    for (const QBluetoothUuid &serviceUuid : services) {
        addDiscoveredService(serviceUuid);
    }
    for (const auto &service : discoveredServices_) {
        if (service.second->state() == QLowEnergyService::DiscoveryRequired) {
            qCDebug(lcDeviceBLE) << this << "Discovering details of service " << service.second->serviceUuid() << " ...";
            service.second->discoverDetails();
        }
    }
}

void BluetoothLowEnergyController::checkServiceDetailsDiscovery()
{
    bool allDiscovered = true;
    for (const auto &service : discoveredServices_) {
        if (service.second->state() == QLowEnergyService::DiscoveringServices) {
            allDiscovered = false;
        }
    }
    if (allDiscovered && allDiscovered_ == false) {
        if (lowEnergyController_->state() == QLowEnergyController::DiscoveredState) {
            allDiscovered_ = true;
            qCDebug(lcDeviceBLE) << this << "Service details discovery finished";
            for (const auto &service : discoveredServices_) {
                qCDebug(lcDeviceBLE) << this << "Service " << service.second->serviceUuid() << " state " << service.second->state();
            }
            if (deleteLater_ == false) {
                openingTimer_.stop();
                emit connected();
            } else {
                lowEnergyController_->disconnectFromDevice();
            }
        } else {
            qCWarning(lcDeviceBLE) << this << "Service details discovery finished, but the BLE device is not open.";
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
        disconnect();
    }
}

void BluetoothLowEnergyController::deviceStateChangeHandler(QLowEnergyController::ControllerState state)
{
    QLowEnergyController *lowEnergyController = qobject_cast<QLowEnergyController*>(QObject::sender());
    if ((lowEnergyController == nullptr) || (lowEnergyController != lowEnergyController_)) {
        return;
    }

    qCDebug(lcDeviceBLE) << this << "Device state changed: " << state;
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

    qCDebug(lcDeviceBLE) << this << "Service state changed: " << newState;
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
    qCDebug(lcDeviceBLE) << this << "Creating service for UUID " << serviceUuid << " ...";
    if (discoveredServices_.count(serviceUuid) != 0) {
        // It is allowed to have multiple services with the same UUID, so this is a correct situation.
        // If multiple services with the same UUID need to be accessed, it should be done via handles (to be implemented later)
        qCInfo(lcDeviceBLE) << this << "Duplicate service UUID " << serviceUuid << ", ignoring the latter.";
        return;
    }
    QLowEnergyService * service = lowEnergyController_->createServiceObject(serviceUuid, lowEnergyController_); // will be automatically deleted after controller is erased
    if (service == nullptr) {
        qCWarning(lcDeviceBLE) << this << "Invalid service";
        return;
    }
    if (service->serviceUuid() != serviceUuid) {
        // this should never happen, but we rely on this condition later, so let's better check it
        qCWarning(lcDeviceBLE) << this << "Invalid service: inconsistent uuid";
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
