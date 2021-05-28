#include "BluetoothLowEnergy/BluetoothLowEnergyDevice.h"
#include "BluetoothLowEnergy/BluetoothLowEnergyJsonEncoder.h"

#include "logging/LoggingQtCategories.h"

#include <QBluetoothUuid>
#include <QLowEnergyController>
#include <QLowEnergyService>
#include <QTimer>
#include <QRandomGenerator>

namespace strata::device {

BluetoothLowEnergyDevice::BluetoothLowEnergyDevice(const QBluetoothDeviceInfo &info)
    : Device(
          createDeviceId(info),
          info.name(),
          Type::BLEDevice),
      bluetoothDeviceInfo_(info),
      allDiscovered_(false)
{

    qCDebug(logCategoryDeviceBLE).nospace().noquote()
        << "Created new BLE device, ID: " << deviceId_
        << ", name: '" << deviceName_ << "'"
        << ", unique ID: 0x" << hex << reinterpret_cast<quintptr>(this);
}

BluetoothLowEnergyDevice::~BluetoothLowEnergyDevice()
{
    qCDebug(logCategoryDeviceBLE).nospace().noquote()
        << "Deleted BLE device, ID: " << deviceId_
        << ", unique ID: 0x" << hex << reinterpret_cast<quintptr>(this);

    deinit();
}

void BluetoothLowEnergyDevice::deinit()
{
    qCDebug(logCategoryDeviceBLE) << this << "Deinitializing BLE device";

    // No need to disconnect here, deleteLater will do it
    // lowEnergyController_->disconnectFromDevice();
    disconnect(lowEnergyController_, nullptr, this, nullptr);
    lowEnergyController_->deleteLater();
    lowEnergyController_ = nullptr;
    for (auto service : discoveredServices_) {
        disconnect(service.second, nullptr, this, nullptr);
        service.second->deleteLater();
    }
    discoveredServices_.clear();
    allDiscovered_ = false;
}

bool BluetoothLowEnergyDevice::open()
{
    connectToDevice();
    return true;
}

void BluetoothLowEnergyDevice::close()
{
    deinit();
}

bool BluetoothLowEnergyDevice::sendMessage(const QByteArray &message)
{
    qCDebug(logCategoryDeviceBLE).nospace().noquote()
        << deviceId_ << message;

    if (processRequest(message) == false) {
        return false;
    }

    emit messageSent(message);
    return true;
}

bool BluetoothLowEnergyDevice::processRequest(const QByteArray &message)
{
    rapidjson::Document requestDocument;
    rapidjson::ParseResult parseResult = requestDocument.Parse(message.data(), message.size());

    if (parseResult.IsError()) {
        return false;
    }

    if (requestDocument.HasMember("cmd") == false) {
        return false;
    }

    auto *cmdObject = &requestDocument["cmd"];
    if (cmdObject->IsString() == false) {
        return false;
    }

    // TODO!!! return real discovered data
    std::string cmd = cmdObject->GetString();
    if (processHardcodedReplies(cmd)) {
        return true;
    }

    // process messages
    if (0 == cmd.compare("write")) {
        return processWriteCommand(requestDocument);
    }
    if (0 == cmd.compare("read")) {
        return processReadCommand(requestDocument);
    }

    return false;
}

bool BluetoothLowEnergyDevice::processWriteCommand(const rapidjson::Document & requestDocument)
{
    if (isConnected() == false) {
        return false;
    }

    BluetoothLowEnergyJsonEncoder::BluetoothLowEnergyAttributes attributes;
    if (BluetoothLowEnergyJsonEncoder::parseRequest(requestDocument, attributes) == false) {
        return false;
    }

    QLowEnergyService * service = getService(attributes.service);
    if (service == nullptr) {
        return false;
    }

    QLowEnergyCharacteristic characteristic = service->characteristic(attributes.characteristic);
    if (characteristic.isValid() == false) {
        qCWarning(logCategoryDeviceBLE) << this << "Invalid characteristic";
        return false;
    }
    if (attributes.descriptor.isNull()) {
        qCDebug(logCategoryDeviceBLE).nospace().noquote() << this << "Writing: service '" << service->serviceUuid() << "' characteristic '" << characteristic.uuid() << "' data '" << attributes.data << "'";
        service->writeCharacteristic(characteristic, attributes.data);
        return true;
    } else
    {
        QLowEnergyDescriptor descriptor = characteristic.descriptor(attributes.descriptor);
        if (descriptor.isValid() == false) {
            qCWarning(logCategoryDeviceBLE) << this << "Invalid descriptor";
            return false;
        }
        qCDebug(logCategoryDeviceBLE).nospace().noquote() << this << "Writing: service '" << service->serviceUuid() << "' characteristic '" << characteristic.uuid() << "' descriptor '" << descriptor.uuid() << "' data '" << attributes.data << "'";
        service->writeDescriptor(descriptor, attributes.data);
        return true;
    }
}

bool BluetoothLowEnergyDevice::processReadCommand(const rapidjson::Document & requestDocument)
{
    if (isConnected() == false) {
        return false;
    }

    BluetoothLowEnergyJsonEncoder::BluetoothLowEnergyAttributes addresses;
    if (BluetoothLowEnergyJsonEncoder::parseRequest(requestDocument, addresses) == false) {
        return false;
    }

    QLowEnergyService * service = getService(addresses.service);
    if (service == nullptr) {
        return false;
    }

    QLowEnergyCharacteristic characteristic = service->characteristic(addresses.characteristic);
    if (characteristic.isValid() == false) {
        qCWarning(logCategoryDeviceBLE) << this << "Invalid characteristic";
        return false;
    }
    if (addresses.descriptor.isNull()) {
        qCDebug(logCategoryDeviceBLE).nospace().noquote() << this << "Reading: service '" << service->serviceUuid() << "' characteristic '" << characteristic.uuid() << "''";
        service->readCharacteristic(characteristic);
        return true;
    } else
    {
        return false; // service->readDescriptor doesn't work... Disabling reading of descriptors. TODO investigate
        QLowEnergyDescriptor descriptor = characteristic.descriptor(addresses.descriptor);
        if (descriptor.isValid() == false) {
            qCWarning(logCategoryDeviceBLE) << this << "Invalid descriptor";
            return false;
        }
        qCDebug(logCategoryDeviceBLE).nospace().noquote() << this << "Reading: service '" << service->serviceUuid() << "' characteristic '" << characteristic.uuid() << "' descriptor '" << descriptor.uuid() << "'";
        service->readDescriptor(descriptor);
        return true;
    }
}

bool BluetoothLowEnergyDevice::processHardcodedReplies(const std::string &cmd)
{
    std::vector<QByteArray> responses;

    if (0 == cmd.compare("get_firmware_info")) {
        responses.push_back(R"({"ack":"get_firmware_info","payload":{"return_value":true,"return_string":"command valid"}})");
        responses.push_back(R"({
    "notification": {
        "value":"get_firmware_info",
        "payload": {
            "api_version":"2.0",
            "active":"application",
            "bootloader": {
                "version":"",
                "date":""
            },
            "application": {
                "version":"",
                "date":""
            }
        }
    }
})");
    }

    if (0 == cmd.compare("request_platform_id")) {
        responses.push_back(R"({"ack":"request_platform_id","payload":{"return_value":true,"return_string":"command valid"}})");
        responses.push_back((R"({
    "notification":{
        "value":"platform_id",
        "payload":{
            "name":")" + bluetoothDeviceInfo_.name() + R"(",
            "controller_type":1,
            "platform_id":")" + bluetoothDeviceInfo_.address().toString() + R"(",
            "class_id":"",
            "board_count":1
        }
    }
})").toUtf8());
    }

    if (responses.empty() == false) {
        emitResponses(responses);

        return true;
    }
    return false;
}

bool BluetoothLowEnergyDevice::isConnected() const
{
    return true; // TODO!!! change after open() will be changed to work asynchronously
    if (lowEnergyController_ == nullptr) {
        return false;
    }

    return lowEnergyController_->state() == QLowEnergyController::DiscoveredState && allDiscovered_; // TODO!!! check that this works
}

void BluetoothLowEnergyDevice::connectToDevice()
{
    if (lowEnergyController_ == nullptr) {
        lowEnergyController_ = QLowEnergyController::createCentral(bluetoothDeviceInfo_, this);
        connect(lowEnergyController_, &QLowEnergyController::discoveryFinished, this, &BluetoothLowEnergyDevice::discoveryFinishedHandler);
        connect(lowEnergyController_, &QLowEnergyController::connected, this, &BluetoothLowEnergyDevice::deviceConnectedHandler);
        connect(lowEnergyController_, &QLowEnergyController::disconnected, this, &BluetoothLowEnergyDevice::deviceDisconnectedHandler);
        connect(lowEnergyController_, (void (QLowEnergyController::*)(QLowEnergyController::Error)) &QLowEnergyController::error,
                this, &BluetoothLowEnergyDevice::deviceErrorReceivedHandler);
        connect(lowEnergyController_, &QLowEnergyController::stateChanged, this, &BluetoothLowEnergyDevice::deviceStateChangeHandler);
    }

    qCDebug(logCategoryDeviceBLE) << this << "Connecting to BLE device...";
    lowEnergyController_->connectToDevice();
}

void BluetoothLowEnergyDevice::deviceConnectedHandler()
{
    qCDebug(logCategoryDeviceBLE) << this << "Device connected, discovering services...";
    emit messageReceived(QByteArray(R"({"notification":{"value":"ble_device_connected"}})")); // TODO remove
    lowEnergyController_->discoverServices();
}

void BluetoothLowEnergyDevice::discoveryFinishedHandler()
{
    qCDebug(logCategoryDeviceBLE) << this << "Service discovery finished, discovering service details...";
    discoverServiceDetails();
}

void BluetoothLowEnergyDevice::discoverServiceDetails()
{
    for (const QBluetoothUuid &serviceUuid : lowEnergyController_->services()) {
        addDiscoveredService(serviceUuid);
    }
    checkServiceDetailsDiscovery();
}

void BluetoothLowEnergyDevice::checkServiceDetailsDiscovery()
{
    bool allDiscovered = true;
    for (const auto &service : discoveredServices_) {
        switch (service.second->state()) {
            case QLowEnergyService::InvalidService:
                break;
            case QLowEnergyService::DiscoveryRequired:
                qCDebug(logCategoryDeviceBLE).nospace().noquote() << this << "Discovering details of service " << service.second->serviceUuid() << " ...";;
                service.second->discoverDetails();
                allDiscovered = false;
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
        allDiscovered_ = true;
        qCDebug(logCategoryDeviceBLE) << this << "Service details discovery finished";
        for (const auto &service : discoveredServices_) {
            qCDebug(logCategoryDeviceBLE).nospace().noquote() << this << "Service " << service.second->serviceUuid() << " state " << service.second->state();
        }
        emit messageReceived(QByteArray(R"({"notification":{"value":"ble_discovery_finished"}})")); // TODO remove
    }
}

void BluetoothLowEnergyDevice::deviceErrorReceivedHandler(QLowEnergyController::Error error)
{
    QString statusString;
    QString errorString = lowEnergyController_->errorString();
    switch(error) {
        case QLowEnergyController::NoError:
            statusString = "no error";
            break;
        case QLowEnergyController::UnknownError:
            statusString = "unknown error";
            break;
        case QLowEnergyController::UnknownRemoteDeviceError:
            statusString = "unknown remote device error";
            break;
        case QLowEnergyController::NetworkError:
            statusString = "network error";
            break;
        case QLowEnergyController::InvalidBluetoothAdapterError:
            statusString = "invalid bluetooth adapter error";
            break;
        case QLowEnergyController::ConnectionError:
            statusString = "connection error";
            break;
        case QLowEnergyController::AdvertisingError:
            statusString = "advertising error";
            break;
        case QLowEnergyController::RemoteHostClosedError:
            statusString = "remote host closed error";
            break;
    }
    qCDebug(logCategoryDeviceBLE).nospace().noquote() << this << "Error: " << error;
    emit messageReceived(BluetoothLowEnergyJsonEncoder::encodeNotificationError(
        statusString.toUtf8(),
        errorString.toUtf8()));
}

void BluetoothLowEnergyDevice::deviceDisconnectedHandler()
{
    emit deviceError(ErrorCode::DeviceDisconnected, "");
    emit messageReceived(QByteArray(R"({"notification":{"value":"ble_device_disconnected"}})")); // TODO remove
    deinit();
}

void BluetoothLowEnergyDevice::deviceStateChangeHandler(QLowEnergyController::ControllerState state)
{
    qCDebug(logCategoryDeviceBLE).nospace().noquote() << this << "Device state changed: " << state;
}

void BluetoothLowEnergyDevice::characteristicWrittenHandler(const QLowEnergyCharacteristic &info, const QByteArray &value)
{
    emit messageReceived(BluetoothLowEnergyJsonEncoder::encodeAckWriteCharacteristic(
        getSignalSenderService(),
        info.uuid().toByteArray(QBluetoothUuid::WithoutBraces),
        value.toHex()));
}

void BluetoothLowEnergyDevice::characteristicReadHandler(const QLowEnergyCharacteristic &info, const QByteArray &value)
{
    emit messageReceived(BluetoothLowEnergyJsonEncoder::encodeAckReadCharacteristic(
        getSignalSenderService(),
        info.uuid().toByteArray(QBluetoothUuid::WithoutBraces)));
    emitResponses(std::vector<QByteArray>({BluetoothLowEnergyJsonEncoder::encodeNotificationReadCharacteristic(
        getSignalSenderService(),
        info.uuid().toByteArray(QBluetoothUuid::WithoutBraces),
        value.toHex())}));
}

void BluetoothLowEnergyDevice::characteristicChangedHandler(const QLowEnergyCharacteristic &info, const QByteArray &value)
{
    emit messageReceived(BluetoothLowEnergyJsonEncoder::encodeNotificationCharacteristic(
        getSignalSenderService(),
        info.uuid().toByteArray(QBluetoothUuid::WithoutBraces),
        value.toHex()));
}

void BluetoothLowEnergyDevice::descriptorWrittenHandler(const QLowEnergyDescriptor &info, const QByteArray &value)
{
    emit messageReceived(BluetoothLowEnergyJsonEncoder::encodeAckWriteDescriptor(
        getSignalSenderService(),
        info.uuid().toByteArray(QBluetoothUuid::WithoutBraces),
        value.toHex()));
}

void BluetoothLowEnergyDevice::descriptorReadHandler(const QLowEnergyDescriptor &info, const QByteArray &value)
{
    emit messageReceived(BluetoothLowEnergyJsonEncoder::encodeAckReadDescriptor(
        getSignalSenderService(),
        info.uuid().toByteArray(QBluetoothUuid::WithoutBraces)));
    emitResponses(std::vector<QByteArray>({BluetoothLowEnergyJsonEncoder::encodeNotificationReadDescriptor(
        getSignalSenderService(),
        info.uuid().toByteArray(QBluetoothUuid::WithoutBraces),
        value.toHex())}));
}

void BluetoothLowEnergyDevice::serviceStateChangedHandler(QLowEnergyService::ServiceState newState)
{
    Q_UNUSED(newState);
    checkServiceDetailsDiscovery();
}

void BluetoothLowEnergyDevice::serviceErrorHandler(QLowEnergyService::ServiceError error)
{
    QString command;
    QString details;
    switch(error) {
        case QLowEnergyService::NoError:
            command = "";
            details = "no error";
            break;
        case QLowEnergyService::OperationError:
            command = "";
            details = "operation error";
            break;
        case QLowEnergyService::CharacteristicWriteError:
            command = "write";
            details = "characteristic write error";
            break;
        case QLowEnergyService::DescriptorWriteError:
            command = "write";
            details = "descriptor write error";
            break;
        case QLowEnergyService::UnknownError:
            command = "";
            details = "unknown error";
            break;
        case QLowEnergyService::CharacteristicReadError:
            command = "read";
            details = "characteristic read error";
            break;
        case QLowEnergyService::DescriptorReadError:
            command = "read";
            details = "descriptor read error";
            break;
    }
    emit messageReceived(BluetoothLowEnergyJsonEncoder::encodeNAck(
        command.toUtf8(),
        details.toUtf8(),
        getSignalSenderService()));
}

void BluetoothLowEnergyDevice::addDiscoveredService(const QBluetoothUuid & serviceUuid)
{
    qCDebug(logCategoryDeviceBLE).nospace().noquote() << this << "Creating service for UUID " << serviceUuid << " ...";
    if (discoveredServices_.count(serviceUuid) != 0) {
        // It is allowed to have multiple services with the same UUID, so this is a correct situation.
        // If multiple services with the same UUID need to be accessed, it should be done via handles (to be implemented later)
        qCInfo(logCategoryDeviceBLE).nospace().noquote() << this << "Duplicate service UUID " << serviceUuid << ", ignoring the latter.";
        return;
    }
    QLowEnergyService * service = lowEnergyController_->createServiceObject(serviceUuid);
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

    connect(service, &QLowEnergyService::characteristicWritten, this, &BluetoothLowEnergyDevice::characteristicWrittenHandler);
    connect(service, &QLowEnergyService::descriptorWritten, this, &BluetoothLowEnergyDevice::descriptorWrittenHandler);
    connect(service, &QLowEnergyService::characteristicRead, this, &BluetoothLowEnergyDevice::characteristicReadHandler);
    connect(service, &QLowEnergyService::descriptorRead, this, &BluetoothLowEnergyDevice::descriptorReadHandler);
    connect(service, &QLowEnergyService::characteristicChanged, this, &BluetoothLowEnergyDevice::characteristicChangedHandler);
    connect(service, (void (QLowEnergyService::*)(QLowEnergyService::ServiceError)) &QLowEnergyService::error, this, &BluetoothLowEnergyDevice::serviceErrorHandler);
    connect(service, &QLowEnergyService::stateChanged, this, &BluetoothLowEnergyDevice::serviceStateChangedHandler);
}

QLowEnergyService * BluetoothLowEnergyDevice::getService(const QBluetoothUuid & serviceUuid)
{
    if (discoveredServices_.count(serviceUuid) == 0) {
        return nullptr;
    }
    return discoveredServices_[serviceUuid];
}

void BluetoothLowEnergyDevice::emitResponses(const std::vector<QByteArray> &responses)
{
    QTimer::singleShot(
        10, this, [=]() {
            for (const QByteArray& response : responses) { // deferred emit (if emitted in the same loop, may cause trouble)
                qCDebug(logCategoryDeviceBLE) << this << "Returning response:" << response;
                emit messageReceived(response);
            }
        });
}

QByteArray BluetoothLowEnergyDevice::getSignalSenderService() const
{
    QByteArray serviceUuid;
    QLowEnergyService *service = qobject_cast<QLowEnergyService*>(QObject::sender());
    if (service != nullptr) {
        serviceUuid = service->serviceUuid().toByteArray(QBluetoothUuid::WithoutBraces);
    }
    return serviceUuid;
}

QByteArray BluetoothLowEnergyDevice::createDeviceId(const QBluetoothDeviceInfo &info)
{
    QByteArray idBase;
    if (info.deviceUuid().isNull() == false) {
        idBase = info.deviceUuid().toByteArray(QBluetoothUuid::WithoutBraces);
    } else if (info.address().isNull() == false) {
        idBase = info.address().toString().toUtf8();
    } else {
        qCWarning(logCategoryDeviceBLE) << "No device ID, using random";
        QVector<quint32> data;
        data.resize(4);
        QRandomGenerator::system()->fillRange(data.data(), data.size());
        for (quint32 value : data) {
            idBase.append((char *)&value, sizeof(value));
        }
    }

    return QByteArray('b' + QByteArray::number(qHash(idBase), 16));
}

}  // namespace
