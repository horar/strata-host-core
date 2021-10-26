/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "BluetoothLowEnergy/BluetoothLowEnergyDevice.h"

#include "logging/LoggingQtCategories.h"

#include <QBluetoothUuid>
#include <QLowEnergyController>
#include <QLowEnergyService>
#include <QTimer>
#include <QRandomGenerator>

namespace strata::device {

BluetoothLowEnergyDevice::BluetoothLowEnergyDevice(const QByteArray& deviceId, const QBluetoothDeviceInfo &info, const BluetoothLowEnergyControllerFactoryPtr& controllerFactory)
    : Device(
          deviceId,
          info.name(),
          Type::BLEDevice),
      platformIdDataAwaiting_(0),
      bluetoothDeviceInfo_(info),
      controllerFactory_(controllerFactory)
{

    qCDebug(lcDeviceBLE).nospace().noquote()
        << "Created new BLE device, ID: " << deviceId_
        << ", name: '" << deviceName_ << "'"
        << ", unique ID: 0x" << hex << reinterpret_cast<quintptr>(this);
}

BluetoothLowEnergyDevice::~BluetoothLowEnergyDevice()
{
    qCDebug(lcDeviceBLE).nospace().noquote()
        << "Deleted BLE device, ID: " << deviceId_
        << ", unique ID: 0x" << hex << reinterpret_cast<quintptr>(this);

    BluetoothLowEnergyDevice::close();
}

void BluetoothLowEnergyDevice::open()
{
    if (controller_ == nullptr) {
        controller_ = controllerFactory_->acquireController(bluetoothDeviceInfo_);

        connect(controller_.get(), &BluetoothLowEnergyController::connected, this, &BluetoothLowEnergyDevice::deviceConnectedHandler);
        connect(controller_.get(), &BluetoothLowEnergyController::disconnected, this, &BluetoothLowEnergyDevice::deviceDisconnectedHandler);
        connect(controller_.get(), &BluetoothLowEnergyController::deviceError, this, &BluetoothLowEnergyDevice::deviceErrorHandler);
        connect(controller_.get(), &BluetoothLowEnergyController::serviceDescriptorWritten, this, &BluetoothLowEnergyDevice::serviceDescriptorWrittenHandler);
        connect(controller_.get(), &BluetoothLowEnergyController::serviceCharacteristicWritten, this, &BluetoothLowEnergyDevice::serviceCharacteristicWrittenHandler);
        connect(controller_.get(), &BluetoothLowEnergyController::serviceCharacteristicRead, this, &BluetoothLowEnergyDevice::serviceCharacteristicReadHandler);
        connect(controller_.get(), &BluetoothLowEnergyController::serviceCharacteristicChanged, this, &BluetoothLowEnergyDevice::serviceCharacteristicChangedHandler);
        connect(controller_.get(), &BluetoothLowEnergyController::serviceError, this, &BluetoothLowEnergyDevice::serviceErrorHandler);

        qCDebug(lcDeviceBLE) << this << "Connecting to BLE device...";
        controller_->open();
    } else {
        qCWarning(lcDeviceBLE) << this << "Already connected to a BLE device";
    }
}

void BluetoothLowEnergyDevice::close()
{
    if (controller_ != nullptr) {
        controller_->close();
        deinit();
    }
}

void BluetoothLowEnergyDevice::deinit()
{
    if (controller_ != nullptr) {
        qCDebug(lcDeviceBLE) << this << "Deinitializing BLE device";

        disconnect(controller_.get(), nullptr, this, nullptr);
        controller_.reset();

        platformIdDataAwaiting_ = 0;
        platformIdentification_.clear();
    }
}

unsigned BluetoothLowEnergyDevice::sendMessage(const QByteArray &message)
{
    qCDebug(lcDeviceBLE).nospace().noquote()
        << deviceId_ << message;

    unsigned msgNum = Device::nextMessageNumber();

    emit messageSent(message, msgNum, processRequest(message));

    return msgNum;
}

QString BluetoothLowEnergyDevice::processRequest(const QByteArray &message)
{
    if (isConnected() == false) {
        qCWarning(lcDeviceBLE) << this << "Not connected, refusing message";
        return "Not connected, refusing message";
    }
    rapidjson::Document requestDocument;
    rapidjson::ParseResult parseResult = requestDocument.Parse(message.data(), message.size());

    if (parseResult.IsError()) {
        qCWarning(lcDeviceBLE) << this << "Unable to parse request";
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
    if (platformIdDataAwaiting_ > 0)
    {
        qCDebug(lcDeviceBLE) << this << "Already requested request_platform_id, will only send 1 result notification";
        return QString();
    }
    platformIdentification_.clear();
    platformIdDataAwaiting_ += sendReadPlatformIdentification(ble::STRATA_ID_SERVICE_CONTROLLER_TYPE);
    platformIdDataAwaiting_ += sendReadPlatformIdentification(ble::STRATA_ID_SERVICE_PLATFORM_ID);
    platformIdDataAwaiting_ += sendReadPlatformIdentification(ble::STRATA_ID_SERVICE_CLASS_ID);
    platformIdDataAwaiting_ += sendReadPlatformIdentification(ble::STRATA_ID_SERVICE_BOARD_COUNT);
    platformIdDataAwaiting_ += sendReadPlatformIdentification(ble::STRATA_ID_SERVICE_BOARD_CONNECTED);
    platformIdDataAwaiting_ += sendReadPlatformIdentification(ble::STRATA_ID_SERVICE_CONTROLLER_PLATFORM_ID);
    platformIdDataAwaiting_ += sendReadPlatformIdentification(ble::STRATA_ID_SERVICE_CONTROLLER_CLASS_ID);
    platformIdDataAwaiting_ += sendReadPlatformIdentification(ble::STRATA_ID_SERVICE_CONTROLLER_BOARD_COUNT);
    platformIdDataAwaiting_ += sendReadPlatformIdentification(ble::STRATA_ID_SERVICE_FW_CLASS_ID);
    if (platformIdDataAwaiting_ == 0) {
        emitResponses({BluetoothLowEnergyJsonEncoder::encodeNAckRequestPlatformId()});
    } else {
        emitResponses({BluetoothLowEnergyJsonEncoder::encodeAckRequestPlatformId()});
    }
    return QString();
}

int BluetoothLowEnergyDevice::sendReadPlatformIdentification(const QBluetoothUuid &characteristicUuid)
{
    QLowEnergyService * service = controller_->getService(ble::STRATA_ID_SERVICE);
    if (service == nullptr) {
        return 0;
    }

    QLowEnergyCharacteristic characteristic = service->characteristic(characteristicUuid);
    if (characteristic.isValid() == false) {
        qCWarning(lcDeviceBLE) << this << "Strata ID characteristic not present:" << characteristicUuid;
        return 0;
    }

    qCDebug(lcDeviceBLE) << this << "Reading: service " << service->serviceUuid() << " characteristic " << characteristic.uuid();
    service->readCharacteristic(characteristic);
    return 1;
}

void BluetoothLowEnergyDevice::platformIdentificationReadHandler(const QBluetoothUuid &characteristicUuid, const QByteArray *value)
{
    if (value != nullptr) {
        BluetoothLowEnergyJsonEncoder::parseCharacteristicValue(characteristicUuid, *value, platformIdentification_);
    }
    platformIdDataAwaiting_--;

    if (platformIdDataAwaiting_ == 0) {
        emitResponses({BluetoothLowEnergyJsonEncoder::encodeNotificationPlatformId(bluetoothDeviceInfo_.name(), platformIdentification_)});
        platformIdentification_.clear();
    } else if (platformIdDataAwaiting_ < 0) {
        platformIdDataAwaiting_ = 0; // just in case the driver sends more responses than we requested -> wrong answer, but no infinite waiting
        platformIdentification_.clear();
        qCWarning(lcDeviceBLE) << this << "Unexpected Strata ID service response" << characteristicUuid;
    }
}


QString BluetoothLowEnergyDevice::processWriteCommand(const rapidjson::Document & requestDocument)
{
    BluetoothLowEnergyJsonEncoder::BluetoothLowEnergyAttribute attribute;
    QString parseError = BluetoothLowEnergyJsonEncoder::parseRequest(requestDocument, attribute);
    if (parseError.isEmpty() == false) {
        return parseError;
    }

    if (attribute.data.isNull()) {
        qCWarning(lcDeviceBLE) << this << "No data";
        return "No data";
    }

    QLowEnergyService * service = controller_->getService(attribute.service);
    if (service == nullptr) {
        return "Invalid service";
    }

    QLowEnergyCharacteristic characteristic = service->characteristic(attribute.characteristic);
    if (characteristic.isValid() == false) {
        qCWarning(lcDeviceBLE) << this << "Invalid characteristic";
        return "Invalid characteristic";
    }

    qCDebug(lcDeviceBLE) << this << "Writing: service " << service->serviceUuid() << " characteristic " << characteristic.uuid() << " data " << attribute.data.toHex();
    service->writeCharacteristic(characteristic, attribute.data);
    return QString();
}

QString BluetoothLowEnergyDevice::processWriteDescriptorCommand(const rapidjson::Document & requestDocument)
{
    BluetoothLowEnergyJsonEncoder::BluetoothLowEnergyAttribute attribute;
    QString parseError = BluetoothLowEnergyJsonEncoder::parseRequest(requestDocument, attribute);
    if (parseError.isEmpty() == false) {
        return parseError;
    }

    if (attribute.data.isNull()) {
        qCWarning(lcDeviceBLE) << this << "No data";
        return "No data";
    }

    QLowEnergyService * service = controller_->getService(attribute.service);
    if (service == nullptr) {
        return "Invalid service";
    }

    QLowEnergyCharacteristic characteristic = service->characteristic(attribute.characteristic);
    if (characteristic.isValid() == false) {
        qCWarning(lcDeviceBLE) << this << "Invalid characteristic";
        return "Invalid characteristic";
    }

    QLowEnergyDescriptor descriptor = characteristic.descriptor(attribute.descriptor);
    if (descriptor.isValid() == false) {
        qCWarning(lcDeviceBLE) << this << "Invalid descriptor";
        return "Invalid descriptor";
    }
    qCDebug(lcDeviceBLE) << this << "Writing: service " << service->serviceUuid() << " characteristic " << characteristic.uuid() << " descriptor " << descriptor.uuid() << " data " << attribute.data.toHex();
    service->writeDescriptor(descriptor, attribute.data);
    return QString();
}

QString BluetoothLowEnergyDevice::processReadCommand(const rapidjson::Document & requestDocument)
{
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

    QLowEnergyService * service = controller_->getService(attribute.service);
    if (service == nullptr) {
        return "Invalid service";
    }

    QLowEnergyCharacteristic characteristic = service->characteristic(attribute.characteristic);
    if (characteristic.isValid() == false) {
        qCWarning(lcDeviceBLE) << this << "Invalid characteristic";
        return "Invalid characteristic";
    }

    qCDebug(lcDeviceBLE) << this << "Reading: service " << service->serviceUuid() << " characteristic " << characteristic.uuid();
    service->readCharacteristic(characteristic);
    return QString();
}

bool BluetoothLowEnergyDevice::isConnected() const
{
    if (controller_ == nullptr) {
        return false;
    }

    return controller_->isConnected();
}

void BluetoothLowEnergyDevice::resetReceiving()
{
    //do nothing for ble device
    return;
}

void BluetoothLowEnergyDevice::deviceConnectedHandler()
{
    emit Device::opened();
    qCDebug(lcDeviceBLE) << this << "Device connected and ready to communicate";
}

void BluetoothLowEnergyDevice::deviceDisconnectedHandler(bool failedToOpen)
{
    qCDebug(lcDeviceBLE) << this << "Device disconnected.";
    deinit();

    if (failedToOpen) {
        emit Device::deviceError(device::Device::ErrorCode::DeviceFailedToOpen, "Unable to connect to BLE device");
    } else {
        emit Device::deviceError(ErrorCode::DeviceDisconnected, "");
    }
}

void BluetoothLowEnergyDevice::deviceErrorHandler(QLowEnergyController::Error error, const QString& errorString)
{
    QString statusString;
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
    qCDebug(lcDeviceBLE) << this << "Error: " << error;
    emit messageReceived(BluetoothLowEnergyJsonEncoder::encodeNotificationError(
        statusString.toUtf8(),
        errorString.toUtf8()));
}

void BluetoothLowEnergyDevice::serviceDescriptorWrittenHandler(const QByteArray& serviceUuid, const QLowEnergyDescriptor &info, const QByteArray &value)
{
    emit messageReceived(BluetoothLowEnergyJsonEncoder::encodeAckWriteDescriptor(
        serviceUuid,
        info.uuid().toByteArray(QBluetoothUuid::WithoutBraces),
        value.toHex()));
}

void BluetoothLowEnergyDevice::serviceCharacteristicWrittenHandler(const QByteArray& serviceUuid, const QLowEnergyCharacteristic &info, const QByteArray &value)
{
    emit messageReceived(BluetoothLowEnergyJsonEncoder::encodeAckWriteCharacteristic(
        serviceUuid,
        info.uuid().toByteArray(QBluetoothUuid::WithoutBraces),
        value.toHex()));
}

void BluetoothLowEnergyDevice::serviceCharacteristicReadHandler(const QByteArray& serviceUuid, const QLowEnergyCharacteristic &info, const QByteArray &value)
{
    if (serviceUuid == ble::STRATA_ID_SERVICE.toByteArray(QBluetoothUuid::WithoutBraces)) {
        platformIdentificationReadHandler(info.uuid(), &value);
        return;
    }

    emit messageReceived(BluetoothLowEnergyJsonEncoder::encodeAckReadCharacteristic(
        serviceUuid,
        info.uuid().toByteArray(QBluetoothUuid::WithoutBraces)));
    emitResponses(std::vector<QByteArray>({BluetoothLowEnergyJsonEncoder::encodeNotificationReadCharacteristic(
        serviceUuid,
        info.uuid().toByteArray(QBluetoothUuid::WithoutBraces),
        value.toHex())}));
}

void BluetoothLowEnergyDevice::serviceCharacteristicChangedHandler(const QByteArray& serviceUuid, const QLowEnergyCharacteristic &info, const QByteArray &value)
{
    emit messageReceived(BluetoothLowEnergyJsonEncoder::encodeNotificationCharacteristic(
        serviceUuid,
        info.uuid().toByteArray(QBluetoothUuid::WithoutBraces),
        value.toHex()));
}

void BluetoothLowEnergyDevice::serviceErrorHandler(const QByteArray& serviceUuid, QLowEnergyService::ServiceError error)
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
            if (serviceUuid == ble::STRATA_ID_SERVICE.toByteArray(QBluetoothUuid::WithoutBraces)) {
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
        serviceUuid));
}

void BluetoothLowEnergyDevice::emitResponses(const std::vector<QByteArray> &responses)
{
    QTimer::singleShot(
        10, this, [=]() {
            for (const QByteArray& response : responses) { // deferred emit (if emitted in the same loop, may cause trouble)
                qCDebug(lcDeviceBLE) << this << "Returning response:" << response;
                emit messageReceived(response);
            }
        });
}

QByteArray BluetoothLowEnergyDevice::createUniqueHash(const QBluetoothDeviceInfo &info)
{
    QByteArray idBase;
    if (info.deviceUuid().isNull() == false) {
        idBase = info.deviceUuid().toByteArray(QBluetoothUuid::WithoutBraces);
    } else if (info.address().isNull() == false) {
        idBase = info.address().toString().toUtf8();
    } else {
        qCWarning(lcDeviceBLE) << "No unique device identifier, using random";
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
