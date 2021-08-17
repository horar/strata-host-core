#include "BluetoothLowEnergy/BluetoothLowEnergyDevice.h"

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
      platforiIdDataAwaiting_(0),
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
    for (const auto& service : discoveredServices_) {
        disconnect(service.second, nullptr, this, nullptr);
        // deleted when lowEnergyController_ is deleted
    }
    discoveredServices_.clear();
    allDiscovered_ = false;
    platforiIdDataAwaiting_ = 0;
    platformIdentification_.clear();
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
    if (lowEnergyController_ != nullptr) {
        if (lowEnergyController_->state() != QLowEnergyController::UnconnectedState) {
            lowEnergyController_->disconnectFromDevice(); // attempt gracefull close, will deinit later
        } else {
            deinit();   // nothing is open, just deinit directly
        }
    }
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

    // process messages
    std::string cmd = cmdObject->GetString();
    if (0 == cmd.compare("get_firmware_info")) {
        return processGetFirmwareInfoCommand();
    }
    if (0 == cmd.compare("request_platform_id")) {
        return processRequestPlatformIdCommand();
    }
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

QString BluetoothLowEnergyDevice::processGetFirmwareInfoCommand()
{
    std::vector<QByteArray> responses;
    responses.push_back(BluetoothLowEnergyJsonEncoder::encodeAckGetFirmwareInfo());
    responses.push_back(BluetoothLowEnergyJsonEncoder::encodeNotificationGetFirmwareInfo());
    emitResponses(responses);
    return QString();
}

QString BluetoothLowEnergyDevice::processRequestPlatformIdCommand()
{
    if (platforiIdDataAwaiting_ > 0)
    {
        qCDebug(logCategoryDeviceBLE) << this << "Already requested request_platform_id, will only send 1 result notification";
        return QString();
    }
    platformIdentification_.clear();
    platforiIdDataAwaiting_ += sendReadPlatformIdentification(ble::STRATA_ID_SERVICE_CONTROLLER_TYPE);
    platforiIdDataAwaiting_ += sendReadPlatformIdentification(ble::STRATA_ID_SERVICE_PLATFORM_ID);
    platforiIdDataAwaiting_ += sendReadPlatformIdentification(ble::STRATA_ID_SERVICE_CLASS_ID);
    platforiIdDataAwaiting_ += sendReadPlatformIdentification(ble::STRATA_ID_SERVICE_BOARD_COUNT);
    platforiIdDataAwaiting_ += sendReadPlatformIdentification(ble::STRATA_ID_SERVICE_BOARD_CONNECTED);
    platforiIdDataAwaiting_ += sendReadPlatformIdentification(ble::STRATA_ID_SERVICE_CONTROLLER_PLATFORM_ID);
    platforiIdDataAwaiting_ += sendReadPlatformIdentification(ble::STRATA_ID_SERVICE_CONTROLLER_CLASS_ID);
    platforiIdDataAwaiting_ += sendReadPlatformIdentification(ble::STRATA_ID_SERVICE_CONTROLLER_BOARD_COUNT);
    platforiIdDataAwaiting_ += sendReadPlatformIdentification(ble::STRATA_ID_SERVICE_FW_CLASS_ID);
    if (platforiIdDataAwaiting_ == 0) {
        emitResponses({BluetoothLowEnergyJsonEncoder::encodeNAckRequestPlatformId()});
    } else {
        emitResponses({BluetoothLowEnergyJsonEncoder::encodeAckRequestPlatformId()});
    }
    return QString();
}

int BluetoothLowEnergyDevice::sendReadPlatformIdentification(const QBluetoothUuid &characteristicUuid)
{
    QLowEnergyService * service = getService(ble::STRATA_ID_SERVICE);
    if (service == nullptr) {
        return 0;
    }

    QLowEnergyCharacteristic characteristic = service->characteristic(characteristicUuid);
    if (characteristic.isValid() == false) {
        qCWarning(logCategoryDeviceBLE) << this << "Strata ID characteristic not present:" << characteristicUuid;
        return 0;
    }

    qCDebug(logCategoryDeviceBLE) << this << "Reading: service " << service->serviceUuid() << " characteristic " << characteristic.uuid();
    service->readCharacteristic(characteristic);
    return 1;
}

void BluetoothLowEnergyDevice::platformIdentificationReadHandler(const QBluetoothUuid &characteristicUuid, const QByteArray *value)
{
    if (value != nullptr) {
        BluetoothLowEnergyJsonEncoder::parseCharacteristicValue(characteristicUuid, *value, platformIdentification_);
    }
    platforiIdDataAwaiting_--;

    if (platforiIdDataAwaiting_ == 0) {
        emitResponses({BluetoothLowEnergyJsonEncoder::encodeNotificationPlatformId(bluetoothDeviceInfo_.name(), platformIdentification_)});
        platformIdentification_.clear();
    } else if (platforiIdDataAwaiting_ < 0) {
        platforiIdDataAwaiting_ = 0; // just in case the driver sends more responses than we requested -> wrong answer, but no infinite waiting
        platformIdentification_.clear();
        qCWarning(logCategoryDeviceBLE) << this << "Unexpected Strata ID service response" << characteristicUuid;
    }
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

    if (attribute.service == ble::STRATA_ID_SERVICE)
    {
        // not handling this for now, would be complicated to support this together with the request_platform_id flow
        return "Reserved service, use request_platform_id instead";
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

    if (lowEnergyController_->state() == QLowEnergyController::UnconnectedState) {
        qCDebug(logCategoryDeviceBLE) << this << "Connecting to BLE device...";
        lowEnergyController_->connectToDevice();
    } else {
        qCWarning(logCategoryDeviceBLE) << this << "Already connected to a BLE device";
    }
}

void BluetoothLowEnergyDevice::deviceConnectedHandler()
{
    QLowEnergyController *lowEnergyController = qobject_cast<QLowEnergyController*>(QObject::sender());
    if ((lowEnergyController == nullptr) || (lowEnergyController != lowEnergyController_)) {
        return;
    }

    qCDebug(logCategoryDeviceBLE) << this << "Device connected, discovering services...";
    lowEnergyController_->discoverServices();
}

void BluetoothLowEnergyDevice::discoveryFinishedHandler()
{
    QLowEnergyController *lowEnergyController = qobject_cast<QLowEnergyController*>(QObject::sender());
    if ((lowEnergyController == nullptr) || (lowEnergyController != lowEnergyController_)) {
        return;
    }

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
    QLowEnergyController *lowEnergyController = qobject_cast<QLowEnergyController*>(QObject::sender());
    if ((lowEnergyController == nullptr) || (lowEnergyController != lowEnergyController_)) {
        return;
    }

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
    QLowEnergyController *lowEnergyController = qobject_cast<QLowEnergyController*>(QObject::sender());
    if ((lowEnergyController == nullptr) || (lowEnergyController != lowEnergyController_)) {
        return;
    }

    qCDebug(logCategoryDeviceBLE) << this << "Device disconnected.";
    emit deviceError(ErrorCode::DeviceDisconnected, "");
    deinit();
}

void BluetoothLowEnergyDevice::deviceStateChangeHandler(QLowEnergyController::ControllerState state)
{
    QLowEnergyController *lowEnergyController = qobject_cast<QLowEnergyController*>(QObject::sender());
    if ((lowEnergyController == nullptr) || (lowEnergyController != lowEnergyController_)) {
        return;
    }

    qCDebug(logCategoryDeviceBLE) << this << "Device state changed: " << state;
}

void BluetoothLowEnergyDevice::characteristicWrittenHandler(const QLowEnergyCharacteristic &info, const QByteArray &value)
{
    QLowEnergyService *service = qobject_cast<QLowEnergyService*>(QObject::sender());
    if ((service == nullptr) || (getService(service->serviceUuid()) != service)) {
        return;
    }

    emit messageReceived(BluetoothLowEnergyJsonEncoder::encodeAckWriteCharacteristic(
        getServiceUuid(service),
        info.uuid().toByteArray(QBluetoothUuid::WithoutBraces),
        value.toHex()));
}

void BluetoothLowEnergyDevice::characteristicReadHandler(const QLowEnergyCharacteristic &info, const QByteArray &value)
{
    QLowEnergyService *service = qobject_cast<QLowEnergyService*>(QObject::sender());
    if ((service == nullptr) || (getService(service->serviceUuid()) != service)) {
        return;
    }

    QByteArray senderService = getServiceUuid(service);
    if (senderService == ble::STRATA_ID_SERVICE.toByteArray(QBluetoothUuid::WithoutBraces)) {
        platformIdentificationReadHandler(info.uuid(), &value);
        return;
    }

    emit messageReceived(BluetoothLowEnergyJsonEncoder::encodeAckReadCharacteristic(
        senderService,
        info.uuid().toByteArray(QBluetoothUuid::WithoutBraces)));
    emitResponses(std::vector<QByteArray>({BluetoothLowEnergyJsonEncoder::encodeNotificationReadCharacteristic(
        senderService,
        info.uuid().toByteArray(QBluetoothUuid::WithoutBraces),
        value.toHex())}));
}

void BluetoothLowEnergyDevice::characteristicChangedHandler(const QLowEnergyCharacteristic &info, const QByteArray &value)
{
    QLowEnergyService *service = qobject_cast<QLowEnergyService*>(QObject::sender());
    if ((service == nullptr) || (getService(service->serviceUuid()) != service)) {
        return;
    }

    emit messageReceived(BluetoothLowEnergyJsonEncoder::encodeNotificationCharacteristic(
        getServiceUuid(service),
        info.uuid().toByteArray(QBluetoothUuid::WithoutBraces),
        value.toHex()));
}

void BluetoothLowEnergyDevice::descriptorWrittenHandler(const QLowEnergyDescriptor &info, const QByteArray &value)
{
    QLowEnergyService *service = qobject_cast<QLowEnergyService*>(QObject::sender());
    if ((service == nullptr) || (getService(service->serviceUuid()) != service)) {
        return;
    }

    emit messageReceived(BluetoothLowEnergyJsonEncoder::encodeAckWriteDescriptor(
        getServiceUuid(service),
        info.uuid().toByteArray(QBluetoothUuid::WithoutBraces),
        value.toHex()));
}

void BluetoothLowEnergyDevice::serviceStateChangedHandler(QLowEnergyService::ServiceState newState)
{
    QLowEnergyService *service = qobject_cast<QLowEnergyService*>(QObject::sender());
    if ((service == nullptr) || (getService(service->serviceUuid()) != service)) {
        return;
    }

    qCDebug(logCategoryDeviceBLE) << this << "Service state changed: " << newState;
    checkServiceDetailsDiscovery();
}

void BluetoothLowEnergyDevice::serviceErrorHandler(QLowEnergyService::ServiceError error)
{
    QLowEnergyService *service = qobject_cast<QLowEnergyService*>(QObject::sender());
    if ((service == nullptr) || (getService(service->serviceUuid()) != service)) {
        return;
    }

    QString command;
    QString details;
    QByteArray senderService = getServiceUuid(service);
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
            if (senderService == ble::STRATA_ID_SERVICE.toByteArray(QBluetoothUuid::WithoutBraces)) {
                platformIdentificationReadHandler(QBluetoothUuid(), nullptr);
                return;
            }
            break;
        case QLowEnergyService::DescriptorReadError:
            command = "read";
            details = "descriptor read error";
            break;
    }
    emit messageReceived(BluetoothLowEnergyJsonEncoder::encodeNAck(
        command.toUtf8(),
        details.toUtf8(),
        senderService));
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

QByteArray BluetoothLowEnergyDevice::getServiceUuid(QLowEnergyService *service) const
{
    return service->serviceUuid().toByteArray(QBluetoothUuid::WithoutBraces);
}

bool BluetoothLowEnergyDevice::isLightningKit() const
{
    return
    0 < discoveredServices_.count(QBluetoothUuid(QStringLiteral("00000001-0001-0362-b5da-012dd27485f8"))) &&
    0 < discoveredServices_.count(QBluetoothUuid(QStringLiteral("00000002-0001-0362-b5da-012dd27485f8"))) &&
    0 < discoveredServices_.count(QBluetoothUuid(QStringLiteral("00000003-0001-0362-b5da-012dd27485f8")));
}

bool BluetoothLowEnergyDevice::isSmartshotDemoCam() const
{
    return
    0 < discoveredServices_.count(QBluetoothUuid(QStringLiteral("00000004-0001-0362-b5da-012dd27485f8"))) &&
    0 < discoveredServices_.count(QBluetoothUuid(QStringLiteral("00000005-0001-0362-b5da-012dd27485f8")));
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
