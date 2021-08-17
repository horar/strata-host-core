#pragma once

#include <map>

#include <QTimer>
#include <QObject>
#include <QByteArray>
#include <QBluetoothUuid>
#include <QBluetoothDeviceInfo>
#include <QLowEnergyController>
#include <QLowEnergyService>

namespace strata::device
{

class BluetoothLowEnergyController final : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(BluetoothLowEnergyController)

public:
    /**
     * BluetoothLowEnergyController constructor
     * @param info bluetooth device info.
     */
    explicit BluetoothLowEnergyController(const QBluetoothDeviceInfo &info, QObject* parent = nullptr);

    /**
     * BluetoothLowEnergyController destructor
     */
    virtual ~BluetoothLowEnergyController() override;

    /**
     * Open device communication channel and discovers services.
     * Emits connected() once device is ready to communicate or disconnected() if failed to open.
     */
    void open();

    /**
     * Tries to close device communication channel if possible (could take some time on Windows).
     * Emits disconnected() immediatelly and finished() once completely closed and device can be erased.
     */
    void close();

    /**
     * Check if device is connected (communication with it is possible).
     * @return true if device is connected, otherwise false
     */
    bool isConnected() const;

    /**
     * Returns service object, identified by serviceUuid. Null if there is no such service discovered.
     * @param serviceUuid UUID of the service.
     * @return service object, identified by serviceUuid. Null if there is no such service discovered.
     */
    QLowEnergyService *getService(const QBluetoothUuid &serviceUuid) const;

signals:
    void connected();
    void disconnected(bool failedToOpen);
    void finished();    // only for BluetoothLowEnergyControllerFactory to erase this object

    void deviceError(QLowEnergyController::Error error, QString errorString);
    void serviceDescriptorWritten(const QByteArray& serviceUuid, const QLowEnergyDescriptor &info, const QByteArray &value);
    void serviceCharacteristicWritten(const QByteArray& serviceUuid, const QLowEnergyCharacteristic &info, const QByteArray &value);
    void serviceCharacteristicRead(const QByteArray& serviceUuid, const QLowEnergyCharacteristic &info, const QByteArray &value);
    void serviceCharacteristicChanged(const QByteArray& serviceUuid, const QLowEnergyCharacteristic &info, const QByteArray &value);
    void serviceError(const QByteArray& serviceUuid, QLowEnergyService::ServiceError error);

private slots:
    void openingTimeoutHandler();

    void deviceConnectedHandler();
    void discoveryFinishedHandler();
    void deviceErrorReceivedHandler(QLowEnergyController::Error error);
    void deviceDisconnectedHandler();
    void deviceStateChangeHandler(QLowEnergyController::ControllerState state);

    void characteristicWrittenHandler(const QLowEnergyCharacteristic &info, const QByteArray &value);
    void descriptorWrittenHandler(const QLowEnergyDescriptor &info, const QByteArray &value);
    void characteristicReadHandler(const QLowEnergyCharacteristic &info, const QByteArray &value);
    void characteristicChangedHandler(const QLowEnergyCharacteristic &info, const QByteArray &value);
    void serviceStateChangedHandler(QLowEnergyService::ServiceState newState);
    void serviceErrorHandler(QLowEnergyService::ServiceError error);

private:
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
     * Returns properly formated service uuid from sender of the signal. Helper function.
     * @return service uuid
     */
    QByteArray getSignalSenderServiceUuid() const;

    bool deleteLater_;
    bool allDiscovered_;
    bool controllerActive_;
    QLowEnergyController *lowEnergyController_;
    std::map<QBluetoothUuid, QLowEnergyService *> discoveredServices_;

    QTimer openingTimer_;
};

typedef std::shared_ptr<BluetoothLowEnergyController> BluetoothLowEnergyControllerPtr;

}  // namespace strata::device
