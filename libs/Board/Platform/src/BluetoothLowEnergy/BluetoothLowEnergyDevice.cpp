#include "BluetoothLowEnergy/BluetoothLowEnergyDevice.h"
#include "BluetoothLowEnergy/BluetoothLowEnergyJsonEncoder.h"

#include "logging/LoggingQtCategories.h"

#include <QBluetoothUuid>
#include <QLowEnergyController>
#include <QLowEnergyService>
#include <QTimer>
#include <QRandomGenerator>

namespace strata::device {

BluetoothLowEnergyDevice::BluetoothLowEnergyDevice(const QByteArray& deviceId, const QBluetoothDeviceInfo &info)
    : Device(
          deviceId,
          info.name(),
          Type::BLEDevice),
      bluetoothDeviceInfo_(info),
      allDiscovered_(false),
      openingTimer_(this)
{

    qCDebug(logCategoryDeviceBLE).nospace().noquote()
        << "Created new BLE device, ID: " << deviceId_
        << ", name: '" << deviceName_ << "'"
        << ", unique ID: 0x" << hex << reinterpret_cast<quintptr>(this);
    openingTimer_.setInterval(std::chrono::seconds(60)); //connect timer, 60s
    openingTimer_.setSingleShot(true);
    connect(&openingTimer_, &QTimer::timeout, this, &BluetoothLowEnergyDevice::openingTimeoutHandler);
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

    if (lowEnergyController_ != nullptr) {
        // No need to close connection here, deleteLater will do it, if not already done
        // lowEnergyController_->disconnectFromDevice();
        disconnect(lowEnergyController_, nullptr, this, nullptr);
        lowEnergyController_->deleteLater();
        lowEnergyController_ = nullptr;
        if (allDiscovered_ == false) {
            notifyOpenFailure();
        }
    }
    for (auto service : discoveredServices_) {
        disconnect(service.second, nullptr, this, nullptr);
        service.second->deleteLater();
    }
    discoveredServices_.clear();
    allDiscovered_ = false;
}

void BluetoothLowEnergyDevice::open()
{
    openingTimer_.start();
    connectToDevice();
}

void BluetoothLowEnergyDevice::openingTimeoutHandler()
{
    qCDebug(logCategoryDeviceBLE) << this << "Timeout while connecting and/or discovering services";
    close();
}

void BluetoothLowEnergyDevice::notifyOpenSuccess()
{
    openingTimer_.stop();
    emit Device::opened();
}

void BluetoothLowEnergyDevice::notifyOpenFailure()
{
    openingTimer_.stop();
    emit Device::deviceError(device::Device::ErrorCode::DeviceFailedToOpen, "Unable to connect to BLE device");
}

void BluetoothLowEnergyDevice::close()
{
    openingTimer_.stop();
    deinit();
}

unsigned BluetoothLowEnergyDevice::sendMessage(const QByteArray &message)
{
    qCDebug(logCategoryDeviceBLE).nospace().noquote()
        << deviceId_ << message;

    unsigned msgNum = Device::nextMessageNumber();

    emit messageSent(message, msgNum, processRequest(message));

    return msgNum;
}

QString BluetoothLowEnergyDevice::processRequest(const QByteArray &message)
{
    if (isConnected() == false) {
        qCWarning(logCategoryDeviceBLE) << this << "Not connected, refusing message";
        return "Not connected, refusing message";
    }
    rapidjson::Document requestDocument;
    rapidjson::ParseResult parseResult = requestDocument.Parse(message.data(), message.size());

    if (parseResult.IsError()) {
        qCWarning(logCategoryDeviceBLE) << this << "Unable to parse request";
        return "Unable to parse request";
    }

    if (requestDocument.HasMember("cmd") == false) {
        return "Missing cmd parameter";
    }

    auto *cmdObject = &requestDocument["cmd"];
    if (cmdObject->IsString() == false) {
        return "Invalid cmd parameter";
    }

    // TODO!!! return real discovered data
    std::string cmd = cmdObject->GetString();
    if (processHardcodedReplies(cmd)) {
        return QString();
    }

    // process messages
    if (0 == cmd.compare("write")) {
        return processWriteCommand(requestDocument);
    }
    if (0 == cmd.compare("write_descriptor")) {
        return processWriteDescriptorCommand(requestDocument);
    }
    if (0 == cmd.compare("read")) {
        return processReadCommand(requestDocument);
    }

    return "Command not supported";
}

QString BluetoothLowEnergyDevice::processWriteCommand(const rapidjson::Document & requestDocument)
{
    if (isConnected() == false) {
        return "Not connected, refusing message";
    }

    BluetoothLowEnergyJsonEncoder::BluetoothLowEnergyAttribute attribute;
    QString parseError = BluetoothLowEnergyJsonEncoder::parseRequest(requestDocument, attribute);
    if (parseError.isEmpty() == false) {
        return parseError;
    }

    if (attribute.data.isNull()) {
        qCWarning(logCategoryDeviceBLE) << this << "No data";
        return "No data";
    }

    QLowEnergyService * service = getService(attribute.service);
    if (service == nullptr) {
        return "Invalid service";
    }

    QLowEnergyCharacteristic characteristic = service->characteristic(attribute.characteristic);
    if (characteristic.isValid() == false) {
        qCWarning(logCategoryDeviceBLE) << this << "Invalid characteristic";
        return "Invalid characteristic";
    }

    qCDebug(logCategoryDeviceBLE) << this << "Writing: service " << service->serviceUuid() << " characteristic " << characteristic.uuid() << " data " << attribute.data.toHex();
    service->writeCharacteristic(characteristic, attribute.data);
    return QString();
}

QString BluetoothLowEnergyDevice::processWriteDescriptorCommand(const rapidjson::Document & requestDocument)
{
    if (isConnected() == false) {
        return "Not connected, refusing message";
    }

    BluetoothLowEnergyJsonEncoder::BluetoothLowEnergyAttribute attribute;
    QString parseError = BluetoothLowEnergyJsonEncoder::parseRequest(requestDocument, attribute);
    if (parseError.isEmpty() == false) {
        return parseError;
    }

    if (attribute.data.isNull()) {
        qCWarning(logCategoryDeviceBLE) << this << "No data";
        return "No data";
    }

    QLowEnergyService * service = getService(attribute.service);
    if (service == nullptr) {
        return "Invalid service";
    }

    QLowEnergyCharacteristic characteristic = service->characteristic(attribute.characteristic);
    if (characteristic.isValid() == false) {
        qCWarning(logCategoryDeviceBLE) << this << "Invalid characteristic";
        return "Invalid characteristic";
    }

    QLowEnergyDescriptor descriptor = characteristic.descriptor(attribute.descriptor);
    if (descriptor.isValid() == false) {
        qCWarning(logCategoryDeviceBLE) << this << "Invalid descriptor";
        return "Invalid descriptor";
    }
    qCDebug(logCategoryDeviceBLE) << this << "Writing: service " << service->serviceUuid() << " characteristic " << characteristic.uuid() << " descriptor " << descriptor.uuid() << " data " << attribute.data.toHex();
    service->writeDescriptor(descriptor, attribute.data);
    return QString();
}

QString BluetoothLowEnergyDevice::processReadCommand(const rapidjson::Document & requestDocument)
{
    if (isConnected() == false) {
        return "Not connected, refusing message";
    }

    BluetoothLowEnergyJsonEncoder::BluetoothLowEnergyAttribute attribute;
    QString parseError = BluetoothLowEnergyJsonEncoder::parseRequest(requestDocument, attribute);
    if (parseError.isEmpty() == false) {
        return parseError;
    }

    QLowEnergyService * service = getService(attribute.service);
    if (service == nullptr) {
        return "Invalid service";
    }

    QLowEnergyCharacteristic characteristic = service->characteristic(attribute.characteristic);
    if (characteristic.isValid() == false) {
        qCWarning(logCategoryDeviceBLE) << this << "Invalid characteristic";
        return "Invalid characteristic";
    }

    qCDebug(logCategoryDeviceBLE) << this << "Reading: service " << service->serviceUuid() << " characteristic " << characteristic.uuid();
    service->readCharacteristic(characteristic);
    return QString();
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
            "bootloader": {},
            "application": {
                "version":"0.0.0",
                "date":""
            }
        }
    }
})");
    }

    if (0 == cmd.compare("request_platform_id")) {
        QString class_id;
        //custom detect Lighting Kit (temporary workaround)
        if (
            0 < discoveredServices_.count(QBluetoothUuid(QString("00000001-0001-0362-b5da-012dd27485f8"))) &&
            0 < discoveredServices_.count(QBluetoothUuid(QString("00000002-0001-0362-b5da-012dd27485f8"))) &&
            0 < discoveredServices_.count(QBluetoothUuid(QString("00000003-0001-0362-b5da-012dd27485f8"))) ) {

            class_id = "d5029d50-9f39-4e44-8c35-589686b511cb";
        }
        //custom detect Smartshot Demo Cam
        if (
            0 < discoveredServices_.count(QBluetoothUuid(QString("00000004-0001-0362-b5da-012dd27485f8"))) &&
            0 < discoveredServices_.count(QBluetoothUuid(QString("00000005-0001-0362-b5da-012dd27485f8"))) ) {

            class_id = "1f2b499c-90a7-4ba6-96a3-5803ca2924e3";
        }

        responses.push_back(R"({"ack":"request_platform_id","payload":{"return_value":true,"return_string":"command valid"}})");
        responses.push_back((R"({
    "notification":{
        "value":"platform_id",
        "payload":{
            "name":")" + bluetoothDeviceInfo_.name() + R"(",
            "controller_type":1,
            "platform_id":")" + bluetoothDeviceInfo_.address().toString() + R"(",
            "class_id":")" + class_id + R"(",
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
    if (lowEnergyController_ == nullptr) {
        return false;
    }

    return lowEnergyController_->state() == QLowEnergyController::DiscoveredState && allDiscovered_;
}

void BluetoothLowEnergyDevice::resetReceiving()
{
    //do nothing for ble device
    return;
}

void BluetoothLowEnergyDevice::connectToDevice()
{
    if (lowEnergyController_ == nullptr) {
        lowEnergyController_ = QLowEnergyController::createCentral(bluetoothDeviceInfo_, this);
        connect(lowEnergyController_, &QLowEnergyController::discoveryFinished, this, &BluetoothLowEnergyDevice::discoveryFinishedHandler, Qt::QueuedConnection);
        connect(lowEnergyController_, &QLowEnergyController::connected, this, &BluetoothLowEnergyDevice::deviceConnectedHandler, Qt::QueuedConnection);
        connect(lowEnergyController_, &QLowEnergyController::disconnected, this, &BluetoothLowEnergyDevice::deviceDisconnectedHandler, Qt::QueuedConnection);
        connect(lowEnergyController_, (void (QLowEnergyController::*)(QLowEnergyController::Error)) &QLowEnergyController::error,
                this, &BluetoothLowEnergyDevice::deviceErrorReceivedHandler, Qt::QueuedConnection);
        connect(lowEnergyController_, &QLowEnergyController::stateChanged, this, &BluetoothLowEnergyDevice::deviceStateChangeHandler, Qt::QueuedConnection);
    }

    qCDebug(logCategoryDeviceBLE) << this << "Connecting to BLE device...";
    lowEnergyController_->connectToDevice();
}

void BluetoothLowEnergyDevice::deviceConnectedHandler()
{
    qCDebug(logCategoryDeviceBLE) << this << "Device connected, discovering services...";
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
                qCDebug(logCategoryDeviceBLE) << this << "Discovering details of service " << service.second->serviceUuid() << " ...";;
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
        if (lowEnergyController_->state() == QLowEnergyController::DiscoveredState) {
            allDiscovered_ = true;
            qCDebug(logCategoryDeviceBLE) << this << "Service details discovery finished";
            for (const auto &service : discoveredServices_) {
                qCDebug(logCategoryDeviceBLE) << this << "Service " << service.second->serviceUuid() << " state " << service.second->state();
            }
            notifyOpenSuccess();
        } else {
            qCWarning(logCategoryDeviceBLE) << this << "Service details discovery finished, but the BLE device is not open.";
            //no need to deinit(), deviceDisconnectedHandler should have been called before this happens
        }
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
    qCDebug(logCategoryDeviceBLE) << this << "Error: " << error;
    if (allDiscovered_ == false) {
        close();
    }
    emit messageReceived(BluetoothLowEnergyJsonEncoder::encodeNotificationError(
        statusString.toUtf8(),
        errorString.toUtf8()));
}

void BluetoothLowEnergyDevice::deviceDisconnectedHandler()
{
    qCDebug(logCategoryDeviceBLE) << this << "Device disconnected.";
    emit deviceError(ErrorCode::DeviceDisconnected, "");
    deinit();
}

void BluetoothLowEnergyDevice::deviceStateChangeHandler(QLowEnergyController::ControllerState state)
{
    qCDebug(logCategoryDeviceBLE) << this << "Device state changed: " << state;
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

void BluetoothLowEnergyDevice::serviceStateChangedHandler(QLowEnergyService::ServiceState newState)
{
    qCDebug(logCategoryDeviceBLE) << this << "Service state changed: " << newState;
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
    qCDebug(logCategoryDeviceBLE) << this << "Creating service for UUID " << serviceUuid << " ...";
    if (discoveredServices_.count(serviceUuid) != 0) {
        // It is allowed to have multiple services with the same UUID, so this is a correct situation.
        // If multiple services with the same UUID need to be accessed, it should be done via handles (to be implemented later)
        qCInfo(logCategoryDeviceBLE) << this << "Duplicate service UUID " << serviceUuid << ", ignoring the latter.";
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

    connect(service, &QLowEnergyService::characteristicWritten, this, &BluetoothLowEnergyDevice::characteristicWrittenHandler, Qt::QueuedConnection);
    connect(service, &QLowEnergyService::descriptorWritten, this, &BluetoothLowEnergyDevice::descriptorWrittenHandler, Qt::QueuedConnection);
    connect(service, &QLowEnergyService::characteristicRead, this, &BluetoothLowEnergyDevice::characteristicReadHandler, Qt::QueuedConnection);
    connect(service, &QLowEnergyService::characteristicChanged, this, &BluetoothLowEnergyDevice::characteristicChangedHandler, Qt::QueuedConnection);
    connect(service, (void (QLowEnergyService::*)(QLowEnergyService::ServiceError)) &QLowEnergyService::error, this, &BluetoothLowEnergyDevice::serviceErrorHandler, Qt::QueuedConnection);
    connect(service, &QLowEnergyService::stateChanged, this, &BluetoothLowEnergyDevice::serviceStateChangedHandler, Qt::QueuedConnection);
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

QByteArray BluetoothLowEnergyDevice::createUniqueHash(const QBluetoothDeviceInfo &info)
{
    QByteArray idBase;
    if (info.deviceUuid().isNull() == false) {
        idBase = info.deviceUuid().toByteArray(QBluetoothUuid::WithoutBraces);
    } else if (info.address().isNull() == false) {
        idBase = info.address().toString().toUtf8();
    } else {
        qCWarning(logCategoryDeviceBLE) << "No unique device identifier, using random";
        QVector<quint32> data;
        data.resize(4);
        QRandomGenerator::system()->fillRange(data.data(), data.size());
        for (quint32 value : data) {
            idBase.append((char *)&value, sizeof(value));
        }
    }

    return QByteArray(QByteArray::number(qHash(idBase), 16));
}

}  // namespace
