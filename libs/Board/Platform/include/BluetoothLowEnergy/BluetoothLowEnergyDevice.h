/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include "BluetoothLowEnergy/BluetoothLowEnergyJsonEncoder.h"
#include <Device.h>
#include <rapidjson/document.h>
#include <QTimer>
#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>
#include "BluetoothLowEnergy/BluetoothLowEnergyControllerFactory.h"

namespace strata::device
{

namespace ble
{
static constexpr quint16 MANUFACTURER_ID_ON_SEMICONDICTOR = 0x0362;
static const QBluetoothUuid STRATA_ID_SERVICE(QString("00010000-297d-4dd5-baf7-5da63e41c884"));
static const QBluetoothUuid STRATA_ID_SERVICE_CONTROLLER_TYPE(QString("00010001-297d-4dd5-baf7-5da63e41c884"));
static const QBluetoothUuid STRATA_ID_SERVICE_PLATFORM_ID(QString("00010002-297d-4dd5-baf7-5da63e41c884"));
static const QBluetoothUuid STRATA_ID_SERVICE_CLASS_ID(QString("00010003-297d-4dd5-baf7-5da63e41c884"));
static const QBluetoothUuid STRATA_ID_SERVICE_BOARD_COUNT(QString("00010004-297d-4dd5-baf7-5da63e41c884"));
static const QBluetoothUuid STRATA_ID_SERVICE_BOARD_CONNECTED(QString("00010005-297d-4dd5-baf7-5da63e41c884"));
static const QBluetoothUuid STRATA_ID_SERVICE_CONTROLLER_PLATFORM_ID(QString("00010006-297d-4dd5-baf7-5da63e41c884"));
static const QBluetoothUuid STRATA_ID_SERVICE_CONTROLLER_CLASS_ID(QString("00010007-297d-4dd5-baf7-5da63e41c884"));
static const QBluetoothUuid STRATA_ID_SERVICE_CONTROLLER_BOARD_COUNT(QString("00010008-297d-4dd5-baf7-5da63e41c884"));
static const QBluetoothUuid STRATA_ID_SERVICE_FW_CLASS_ID(QString("00010009-297d-4dd5-baf7-5da63e41c884"));
} // namespace ble

class BluetoothLowEnergyDevice : public Device
{
    Q_OBJECT
    Q_DISABLE_COPY(BluetoothLowEnergyDevice)

public:

    /**
     * BluetoothLowEnergyDevice constructor
     * @param deviceId device ID
     * @param name device name
     */
    BluetoothLowEnergyDevice(const QByteArray& deviceId, const QBluetoothDeviceInfo &info, const BluetoothLowEnergyControllerFactoryPtr& controllerFactory);

    /**
     * BluetoothLowEnergyDevice destructor
     */
    ~BluetoothLowEnergyDevice() override;

    /**
     * Open device communication channel and discovers services.
     * Emits opened() on success or deviceError(DeviceFailedToOpen, ...) on failure.
     */
    virtual void open() override;

    /**
     * Close device communication channel.
     */
    virtual void close() override;

    /**
     * Send message to device. Emits deviceError() signal in case of failure.
     * @param msg message to be written to device
     * @return serial number of the sent message
     */
    virtual unsigned sendMessage(const QByteArray& msg) override;

    /**
     * Check if device is connected (communication with it is possible).
     * @return true if device is connected, otherwise false
     */
    virtual bool isConnected() const override;

    /**
     * Creates unique hash, based on discovered data.
     * Will be used to generate device ID.
     * @param info Info about discovered BLE device.
     * @return unique hash bytes.
     */
    static QByteArray createUniqueHash(const QBluetoothDeviceInfo &info);

    virtual void resetReceiving() override;

private slots:
    void deviceConnectedHandler();
    void deviceDisconnectedHandler(bool failedToOpen);
    void deviceErrorHandler(QLowEnergyController::Error error, const QString& errorString);

    void serviceDescriptorWrittenHandler(const QByteArray& serviceUuid, const QLowEnergyDescriptor &info, const QByteArray &value);
    void serviceCharacteristicWrittenHandler(const QByteArray& serviceUuid, const QLowEnergyCharacteristic &info, const QByteArray &value);
    void serviceCharacteristicReadHandler(const QByteArray& serviceUuid, const QLowEnergyCharacteristic &info, const QByteArray &value);
    void serviceCharacteristicChangedHandler(const QByteArray& serviceUuid, const QLowEnergyCharacteristic &info, const QByteArray &value);
    void serviceErrorHandler(const QByteArray& serviceUuid, QLowEnergyService::ServiceError error);

private:
    /**
     * Deinitializes the object, deletes stored objects.
     */
    void deinit();

    /**
     * Processes a message for the BLE device. Converts the JSON message to GATT commands.
     * @param message Request for the BLE device.
     * @return error message. Or null string if message was correct and processed.
     */
    [[nodiscard]] QString processRequest(const QByteArray &message);
    /**
     * Reads firmware info from BLE device.
     * Current implementation (no FOTA support) only sends hard-coded response.
     * @return error message. Or null string if message was correct and processed.
     */
    [[nodiscard]] QString processGetFirmwareInfoCommand();
    /**
     * Reads platform identification info from BLE device.
     * @return error message. Or null string if message was correct and processed.
     */
    [[nodiscard]] QString processRequestPlatformIdCommand();
    /**
     * Forwards write command to BLE device.
     * @param requestDocument request with the command.
     * @return error message. Or null string if message was correct and processed.
     */
    [[nodiscard]] QString processWriteCommand(const rapidjson::Document &requestDocument);
    /**
     * Forwards write descriptor command to BLE device.
     * @param requestDocument request with the command.
     * @return error message. Or null string if message was correct and processed.
     */
    [[nodiscard]] QString processWriteDescriptorCommand(const rapidjson::Document &requestDocument);
    /**
     * Forwards read command to BLE device.
     * @param requestDocument request with the command.
     * @return error message. Or null string if message was correct and processed.
     */
    [[nodiscard]] QString processReadCommand(const rapidjson::Document &requestDocument);

    /**
     * Reads (requests read) one characteristic from the Strata ID service.
     * @param characteristicUuid UUID of the characteristic to be read.
     * @return count of expected responses:
     * 1 if read was requested, 0 if request was not sent (e.g. unknown characteristic).
     */
    int sendReadPlatformIdentification(const QBluetoothUuid &characteristicUuid);
    /**
     * Processes response to reading from Strata ID service.
     * @param characteristicUuid UUID of read characteristic.
     * @param value read value, null in case of error.
     */
    void platformIdentificationReadHandler(const QBluetoothUuid &characteristicUuid, const QByteArray *value);

    /**
     * Emits messageReceived. Emits with delay, to prevent possible timing issues.
     * @param responses Responses to be emitted as messageReceived.
     */
    void emitResponses(const std::vector<QByteArray> &responses);

    int platformIdDataAwaiting_;
    QMap<QBluetoothUuid, QString> platformIdentification_;

    QBluetoothDeviceInfo bluetoothDeviceInfo_;
    BluetoothLowEnergyControllerPtr controller_;
    BluetoothLowEnergyControllerFactoryPtr controllerFactory_;
};

}  // namespace strata::device
