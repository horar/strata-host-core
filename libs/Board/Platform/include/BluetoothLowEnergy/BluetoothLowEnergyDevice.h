#pragma once

#include <Device.h>
#include <rapidjson/document.h>
#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>

namespace strata::device
{
struct BluetoothLowEnergyAttributes {
    QBluetoothUuid service;
    QBluetoothUuid characteristic;
    QBluetoothUuid descriptor;
    QByteArray data;
};

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
    BluetoothLowEnergyDevice(const QBluetoothDeviceInfo &info);

    /**
     * BluetoothLowEnergyDevice destructor
     */
    ~BluetoothLowEnergyDevice() override;

    /**
     * Open device communication channel.
     * @return true if device was opened, otherwise false
     */
    virtual bool open() override;

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
     * Parses GATT related data out of JSON request.
     * @param requestDocument Document to be parsed.
     * @param[out] addresses After successful call, will contained parsed data.
     * @return true iff document was parsed successfully.
     */
    [[nodiscard]] static bool parseRequest(const rapidjson::Document &requestDocument,
                                           BluetoothLowEnergyAttributes &addresses);
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
    // If uuid is invalid, returns null uuid (00000000-0000- ...)
    /**
     * Creates QBluetoothUuid from string. Accepts 2B, 4B and 32B UUIDs.
     * If uuid is invalid, returns null uuid (00000000-0000-0000-0000-000000000000)
     * @param uuid UUID string to be processed.
     * @return QBluetoothUuid based on the UUID string.
     */
    static QBluetoothUuid normalizeBleUuid(std::string uuid);
    /**
     * Creates device ID string, based on discovered data.
     * @param info Info about discovered BLE device.
     * @return device ID.
     */
    static QByteArray createDeviceId(const QBluetoothDeviceInfo &info);

    QByteArray deviceId_;

    QBluetoothDeviceInfo bluetoothDeviceInfo_;
    QLowEnergyController *lowEnergyController_{nullptr};
    std::map<QBluetoothUuid, QLowEnergyService *> discoveredServices_;
};

}  // namespace strata::device
