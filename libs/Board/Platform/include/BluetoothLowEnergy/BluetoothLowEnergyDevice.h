#pragma once

#include "BluetoothLowEnergy/BluetoothLowEnergyJsonEncoder.h"
#include <Device.h>
#include <rapidjson/document.h>
#include <QTimer>
#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

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
    BluetoothLowEnergyDevice(const QByteArray& deviceId, const QBluetoothDeviceInfo &info);

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
    void openingTimeoutHandler();

    void deviceConnectedHandler();
    void discoveryFinishedHandler();
    void deviceErrorReceivedHandler(QLowEnergyController::Error error);
    void deviceDisconnectedHandler();
    void deviceStateChangeHandler(QLowEnergyController::ControllerState state);

    void characteristicWrittenHandler(const QLowEnergyCharacteristic &info,
                                      const QByteArray &value);
    void descriptorWrittenHandler(const QLowEnergyDescriptor &info, const QByteArray &value);
    void characteristicReadHandler(const QLowEnergyCharacteristic &info, const QByteArray &value);
    void characteristicChangedHandler(const QLowEnergyCharacteristic &info,
                                      const QByteArray &value);
    void serviceStateChangedHandler(QLowEnergyService::ServiceState newState);
    void serviceErrorHandler(QLowEnergyService::ServiceError error);

private:
    /**
     * Processing after opening of device (including service scan) successfully ends.
     */
    void notifyOpenSuccess();

    /**
     * Processing after opening of device (including service scan) failed.
     */
    void notifyOpenFailure();

    /**
     * Deinitializes the object, deletes stored objects.
     */
    void deinit();

    /**
     * Tries to connect to the device identified by bluetoothDeviceInfo_
     */
    void connectToDevice();

    /**
     * Starts detail discovery for all discovered services.
     */
    void discoverServiceDetails();

    /**
     * Checks the state of service details discovery.
     * Runs discovery where necessary, notifies about complete discovery.
     */
    void checkServiceDetailsDiscovery();

    /**
     * Creates a service object and stores it into internal map
     * @param serviceUuid UUID of the service.
     */
    void addDiscoveredService(const QBluetoothUuid &serviceUuid);

    /**
     * Returns service object, identified by serviceUuid. Null if there is no such service discovered.
     * @param serviceUuid UUID of the service.
     * @return service object, identified by serviceUuid. Null if there is no such service discovered.
     */
    QLowEnergyService *getService(const QBluetoothUuid &serviceUuid);

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

    /**
     * Returns properly formated service uuid. Helper function.
     * @return service uuid
     */
    QByteArray getServiceUuid(QLowEnergyService *service) const;

    /**
     * Temporary workaround for custom detection of Lighting Kit
     * @return true if detected Lighting Kit, false otherwise
     */
    bool isLightningKit() const;

    /**
     * Temporary workaround for custom detection of Smartshot Demo Cam
     * @return true if detected Smartshot Demo Cam, false otherwise
     */
    bool isSmartshotDemoCam() const;

    QBluetoothDeviceInfo bluetoothDeviceInfo_;
    QLowEnergyController *lowEnergyController_{nullptr};
    std::map<QBluetoothUuid, QLowEnergyService *> discoveredServices_;
    bool allDiscovered_;

    int platforiIdDataAwaiting_;
    QMap<QBluetoothUuid, QString> platformIdentification_;

    QTimer openingTimer_;
};

}  // namespace strata::device
