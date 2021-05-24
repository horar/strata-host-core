#include "BluetoothLowEnergy/BluetoothLowEnergyDevice.h"

#include "logging/LoggingQtCategories.h"

#include <QBluetoothUuid>
#include <QLowEnergyController>
#include <QLowEnergyService>
#include <QTimer>

namespace strata::device {

BluetoothLowEnergyDevice::BluetoothLowEnergyDevice(const QBluetoothDeviceInfo &info)
    : Device(
          createDeviceId(info),
          info.name(),
          Type::BLEDevice),
      bluetoothDeviceInfo_(info)
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
    // No need to disconnect here, deleteLater will do it
    // lowEnergyController_->disconnectFromDevice();
    lowEnergyController_->deleteLater();
    lowEnergyController_ = nullptr;
    for (auto service : discoveredServices_) {
        service.second->deleteLater();
    }
    discoveredServices_.clear();
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

    //TODO!!! return real discovered data
    std::string cmd = cmdObject->GetString();
    if (processHardcodedReplies(cmd)) {
        return true;
    }

    //process messages
    if (0 == cmd.compare("write")) {
        return processWriteCommand(requestDocument);
    }
    if (0 == cmd.compare("read")) {
        return processReadCommand(requestDocument);
    }

    return false;
}

bool BluetoothLowEnergyDevice::parseRequest(const rapidjson::Document & requestDocument, BluetoothLowEnergyAttributes & addresses)
{
    if (requestDocument.HasMember("payload") == false) {
        qCWarning(logCategoryDeviceBLE) << "Request missing payload";
        return false;
    }

    auto *payloadObject = &requestDocument["payload"];
    if (payloadObject->IsObject() == false) {
        qCWarning(logCategoryDeviceBLE) << "Payload is not an object";
        return false;
    }

    const rapidjson::GenericObject payload = payloadObject->GetObject();

    std::string serviceUuid;
    if (payload.HasMember("service") && payload["service"].IsString()) {
        serviceUuid = payload["service"].GetString();
    } else {
        qCWarning(logCategoryDeviceBLE) << "Request missing service";
        return false;
    }

    std::string characteristicUuid;
    if (payload.HasMember("characteristic") && payload["characteristic"].IsString()) {
        characteristicUuid = payload["characteristic"].GetString();
    } else {
        qCWarning(logCategoryDeviceBLE) << "Request missing characteristic";
        return false;
    }

    std::string descriptorUuid;
    if (payload.HasMember("descriptor")) {
        if (payload["descriptor"].IsString()) {
            descriptorUuid = payload["descriptor"].GetString();
        } else {
            qCWarning(logCategoryDeviceBLE) << "Request missing descriptor";
            return false;
        }
    }

    QBluetoothUuid serviceUuidObject = normalizeBleUuid(serviceUuid);
    if (serviceUuidObject.isNull())
    {
        qCWarning(logCategoryDeviceBLE) << "Invalid service uuid";
        return false;
    }
    QBluetoothUuid characteristicUuidObject = normalizeBleUuid(characteristicUuid);
    if (characteristicUuidObject.isNull())
    {
        qCWarning(logCategoryDeviceBLE) << "Invalid characteristic uuid";
        return false;
    }
    QBluetoothUuid descriptorUuidObject;
    if (descriptorUuid.empty() == false) {
        descriptorUuidObject = normalizeBleUuid(descriptorUuid);
        if (descriptorUuidObject.isNull())
        {
            qCWarning(logCategoryDeviceBLE) << "Invalid descriptor uuid";
            return false;
        }
    }
    std::string data;
    if (payload.HasMember("data") && payload["data"].IsString()) {
        data = payload["data"].GetString();
    }
    QByteArray dataObject = QByteArray::fromHex(data.c_str());

    addresses.service = serviceUuidObject;
    addresses.characteristic = characteristicUuidObject;
    addresses.descriptor = descriptorUuidObject;
    addresses.data = dataObject;
    return true;
}

bool BluetoothLowEnergyDevice::processWriteCommand(const rapidjson::Document & requestDocument)
{
    if (isConnected() == false) {
        return false;
    }

    BluetoothLowEnergyAttributes attributes;
    if (parseRequest(requestDocument, attributes) == false) {
        return false;
    }

    QLowEnergyService * service = getService(attributes.service);
    if (service == nullptr) {
        return false;
    }

    service->discoverDetails();//TODO!!! move to initial discovery

    QLowEnergyCharacteristic characteristic = service->characteristic(attributes.characteristic);
    if (characteristic.isValid() == false) {
        qWarning(logCategoryDeviceBLE) << "Invalid characteristic";
        return false;
    }
    if (attributes.descriptor.isNull()) {
        qDebug(logCategoryDeviceBLE).nospace().noquote() << "writing: service '" << service->serviceUuid() << "' characteristic '" << characteristic.uuid() << "' data '" << attributes.data << "'";
        service->writeCharacteristic(characteristic, attributes.data);
        return true;
    } else
    {
        QLowEnergyDescriptor descriptor = characteristic.descriptor(attributes.descriptor);
        if (descriptor.isValid() == false) {
            qWarning(logCategoryDeviceBLE) << "Invalid descriptor";
            return false;
        }
        qDebug(logCategoryDeviceBLE).nospace().noquote() << "writing: service '" << service->serviceUuid() << "' characteristic '" << characteristic.uuid() << "' descriptor '" << descriptor.uuid() << "' data '" << attributes.data << "'";
        service->writeDescriptor(descriptor, attributes.data);
        return true;
    }
}

bool BluetoothLowEnergyDevice::processReadCommand(const rapidjson::Document & requestDocument)
{
    if (isConnected() == false) {
        return false;
    }

    BluetoothLowEnergyAttributes addresses;
    if (parseRequest(requestDocument, addresses) == false) {
        return false;
    }

    QLowEnergyService * service = getService(addresses.service);
    if (service == nullptr) {
        return false;
    }

    service->discoverDetails();//TODO!!! move to initial discovery

    QLowEnergyCharacteristic characteristic = service->characteristic(addresses.characteristic);
    if (characteristic.isValid() == false) {
        qWarning(logCategoryDeviceBLE) << "Invalid characteristic";
        return false;
    }
    if (addresses.descriptor.isNull()) {
        qDebug(logCategoryDeviceBLE).nospace().noquote() << "reading: service '" << service->serviceUuid() << "' characteristic '" << characteristic.uuid() << "''";
        service->readCharacteristic(characteristic);
        return true;
    } else
    {
        return false; //service->readDescriptor doesn't work... Disabling reading of descriptors. TODO investigate
        QLowEnergyDescriptor descriptor = characteristic.descriptor(addresses.descriptor);
        if (descriptor.isValid() == false) {
            qWarning(logCategoryDeviceBLE) << "Invalid descriptor";
            return false;
        }
        qDebug(logCategoryDeviceBLE).nospace().noquote() << "reading: service '" << service->serviceUuid() << "' characteristic '" << characteristic.uuid() << "' descriptor '" << descriptor.uuid() << "'";
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
    return true; //TODO!!! change after open() will be changed to work asynchronously
    if (lowEnergyController_ == nullptr) {
        return false;
    }

    return lowEnergyController_->state() == QLowEnergyController::DiscoveredState;//TODO!!! check that this works
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

    qCDebug(logCategoryDeviceBLE) << "Connecting to BLE device...";
    lowEnergyController_->connectToDevice();
}

void BluetoothLowEnergyDevice::deviceConnectedHandler()
{
    emit messageReceived(QByteArray(R"({"notification":{"value":"ble_device_connected"}})"));//TODO remove
    lowEnergyController_->discoverServices();
}

void BluetoothLowEnergyDevice::discoveryFinishedHandler()
{
    emit messageReceived(QByteArray(R"({"notification":{"value":"ble_discovery_finished"}})"));//TODO remove
    //TODO discover characteristics for all services
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
    emit messageReceived(QByteArray(R"({"notification":{"value":"error","payload":{"status":")" + statusString.toUtf8() + R"(","details":")" + errorString.toUtf8() + R"("}}})"));
    //TODO maybe also notify platform manager to disconnect device? emit deviceError(errorCode, errorString);
}

void BluetoothLowEnergyDevice::deviceDisconnectedHandler()
{
    emit deviceError(ErrorCode::DeviceDisconnected, "");
    emit messageReceived(QByteArray(R"({"notification":{"value":"ble_device_disconnected"}})"));//TODO remove
    deinit();
}

void BluetoothLowEnergyDevice::deviceStateChangeHandler(QLowEnergyController::ControllerState state)
{
    //TODO!!!
}

void BluetoothLowEnergyDevice::characteristicWrittenHandler(const QLowEnergyCharacteristic &info, const QByteArray &value)
{
    emit messageReceived(QByteArray(R"({"ack":"write","payload":{"return_value":true,"return_string":"command valid","service":")" + getSignalSenderService() + R"(","characteristic":")" + info.uuid().toByteArray(QBluetoothUuid::WithoutBraces) + R"(","data":")" + value.toHex() + R"("}})"));//TODO take out the constant
}

void BluetoothLowEnergyDevice::characteristicReadHandler(const QLowEnergyCharacteristic &info, const QByteArray &value)
{
    emit messageReceived(QByteArray(R"({"ack":"read","payload":{"return_value":true,"return_string":"command valid"}})"));//TODO take out the constant
    emitResponses(std::vector<QByteArray>({R"({"notification":{"value":"read","payload":{"service":")" + getSignalSenderService() + R"(","characteristic":")" + info.uuid().toByteArray(QBluetoothUuid::WithoutBraces) + R"(","data":")" + value.toHex() + R"("}}})"}));//TODO take out the constant
}

void BluetoothLowEnergyDevice::characteristicChangedHandler(const QLowEnergyCharacteristic &info, const QByteArray &value)
{
    emit messageReceived(QByteArray(R"({"notification":{"value":"notify","payload":{"service":")" + getSignalSenderService() + R"(","characteristic":")" + info.uuid().toByteArray(QBluetoothUuid::WithoutBraces) + R"(","data":")" + value.toHex() + R"("}}})"));//TODO take out the constant
}

void BluetoothLowEnergyDevice::descriptorWrittenHandler(const QLowEnergyDescriptor &info, const QByteArray &value)
{
    emit messageReceived(QByteArray(R"({"ack":"write","payload":{"return_value":true,"return_string":"command valid","service":")" + getSignalSenderService() + R"(","descriptor":")" + info.uuid().toByteArray(QBluetoothUuid::WithoutBraces) + R"(","data":")" + value.toHex() + R"("}})"));//TODO take out the constant
}

void BluetoothLowEnergyDevice::descriptorReadHandler(const QLowEnergyDescriptor &info, const QByteArray &value)
{
    emit messageReceived(QByteArray(R"({"ack":"read","payload":{"return_value":true,"return_string":"command valid"}})"));//TODO take out the constant
    emitResponses(std::vector<QByteArray>({R"({"notification":{"value":"read","payload":{"service":")" + getSignalSenderService() + R"(","descriptor":")" + info.uuid().toByteArray(QBluetoothUuid::WithoutBraces) + R"(","data":")" + value.toHex() + R"("}}})"}));//TODO take out the constant
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
    emit messageReceived(QByteArray(R"({"ack":")" + command.toUtf8() + R"(","payload":{"return_value":false,"return_string":")" + details.toUtf8() + R"(","service":")" + getSignalSenderService() + R"("}})"));//TODO take out the constant
}

void BluetoothLowEnergyDevice::addDiscoveredService(const QBluetoothUuid & serviceUuid)
{
    qDebug(logCategoryDeviceBLE).nospace().noquote() << "Creating service for UUID '" << serviceUuid << "' ...";
    QLowEnergyService * service = lowEnergyController_->createServiceObject(serviceUuid);
    if (service == nullptr) {
        qWarning(logCategoryDeviceBLE) << "Invalid service";
        return;
    }
    if (service->serviceUuid() != serviceUuid) {
        //this should never happen, but we rely on this condition later, so let's better check it
        qWarning(logCategoryDeviceBLE) << "Invalid service: inconsistent uuid";
        delete service;
        return;
    }
    if (discoveredServices_.count(service->serviceUuid()) != 0) {
        //It is allowed to have multiple services with the same UUID, so this is a correct situation.
        //If multiple services with the same UUID need to be accessed, it should be done via handles (to be implemented later)
        qCInfo(logCategoryDeviceBLE).nospace().noquote() << "Duplicate service UUID " << service->serviceUuid() << ", ignoring the latter.";
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
}

QLowEnergyService * BluetoothLowEnergyDevice::getService(const QBluetoothUuid & serviceUuid)
{
    if (discoveredServices_.count(serviceUuid) == 0) {
        addDiscoveredService(serviceUuid); //TODO!!! call during service discovery
    }

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

QBluetoothUuid BluetoothLowEnergyDevice::normalizeBleUuid(std::string uuid)
{
    QString tmpUuid = QString::fromStdString(uuid);
    tmpUuid = tmpUuid.remove('-').toLower();
    for (const auto &ch : tmpUuid) {
        if ((ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= "f")) {
            continue;
        }
        return QBluetoothUuid();//error
    }

    if (tmpUuid.length() == 32) {
        tmpUuid.insert(8, '-').insert(13, '-').insert(18, '-').insert(23, '-');
    } else if (tmpUuid.length() == 8) {
        tmpUuid = tmpUuid + "-0000-1000-8000-00805f9b34fb";
    } else if (tmpUuid.length() == 4) {
        tmpUuid = "0000" + tmpUuid + "-0000-1000-8000-00805f9b34fb";
    } else {
        return QBluetoothUuid();//error
    }
    tmpUuid = '{' + tmpUuid + '}';
    return QBluetoothUuid(tmpUuid);
}

QByteArray BluetoothLowEnergyDevice::createDeviceId(const QBluetoothDeviceInfo &info)
{
    if (info.deviceUuid().isNull() == false) {
        return info.deviceUuid().toByteArray(QBluetoothUuid::WithoutBraces);
    }
    if (info.address().isNull() == false) {
        return info.address().toString().toUtf8();
    }

    qWarning(logCategoryDeviceBLE)  << "No device ID, using empty";
    return QByteArray();
}

}  // namespace
