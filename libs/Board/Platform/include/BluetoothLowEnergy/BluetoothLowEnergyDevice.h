#pragma once

#include <Device.h>
#include <rapidjson/document.h>
#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

namespace strata::device
{

class BluetoothLowEnergyDevice : public Device
{
    Q_OBJECT
    Q_DISABLE_COPY(BluetoothLowEnergyDevice)

public:
    constexpr static quint16 MANUFACTURER_ID_ON_SEMICONDICTOR = 0x0362;

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
     * Send message to device.
     * @param message message to be written to device
     * @return true if message can be sent, otherwise false
     */
    virtual bool sendMessage(const QByteArray &message) override;

    /**
     * Check if device is connected (communication with it is possible).
     * @return true if device is connected, otherwise false
     */
    virtual bool isConnected() const override;

    /**
     * Creates device ID string, based on discovered data.
     * @param info Info about discovered BLE device.
     * @return device ID.
     */
    static QByteArray createDeviceId(const QBluetoothDeviceInfo &info);

private slots:
    void deviceConnectedHandler();
    void discoveryFinishedHandler();
    void deviceErrorReceivedHandler(QLowEnergyController::Error error);
    void deviceDisconnectedHandler();
    void deviceStateChangeHandler(QLowEnergyController::ControllerState state);

    void characteristicWrittenHandler(const QLowEnergyCharacteristic &info,
                                      const QByteArray &value);
    void descriptorWrittenHandler(const QLowEnergyDescriptor &info, const QByteArray &value);
    void characteristicReadHandler(const QLowEnergyCharacteristic &info, const QByteArray &value);
    void descriptorReadHandler(const QLowEnergyDescriptor &info, const QByteArray &value);
    void characteristicChangedHandler(const QLowEnergyCharacteristic &info,
                                      const QByteArray &value);
    void serviceStateChangedHandler(QLowEnergyService::ServiceState newState);
    void serviceErrorHandler(QLowEnergyService::ServiceError error);

private:
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
     * @return true iff message was correct and processed.
     */
    [[nodiscard]] bool processRequest(const QByteArray &message);
    /**
     * Forwards write command to BLE device.
     * @param requestDocument request with the command.
     * @return true iff message was correct and processed.
     */
    [[nodiscard]] bool processWriteCommand(const rapidjson::Document &requestDocument);
    /**
     * Forwards read command to BLE device.
     * @param requestDocument request with the command.
     * @return true iff message was correct and processed.
     */
    [[nodiscard]] bool processReadCommand(const rapidjson::Document &requestDocument);
    /**
     * Temporary workaround, until discovery is implemented, returnshard-coded responses to
     * get_firmware_info and request_platform_id.
     * @param cmd command to be processed.
     * @return true iff message was processed.
     */
    [[nodiscard]] bool processHardcodedReplies(const std::string &cmd);  // TODO!!! remove

    /**
     * Emits messageReceived. Emits with delay, to prevent possible timing issues.
     * @param responses Responses to be emitted as messageReceived.
     */
    void emitResponses(const std::vector<QByteArray> &responses);

    /**
     * Returns sender service of signal. Helper function.
     * @return sender service of signal
     */
    QByteArray getSignalSenderService() const;

    QBluetoothDeviceInfo bluetoothDeviceInfo_;
    QLowEnergyController *lowEnergyController_{nullptr};
    std::map<QBluetoothUuid, QLowEnergyService *> discoveredServices_;
    bool allDiscovered_;
};

}  // namespace strata::device
