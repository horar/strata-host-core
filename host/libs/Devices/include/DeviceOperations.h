#ifndef DEVICE_OPERATIONS_H
#define DEVICE_OPERATIONS_H

#include <vector>
#include <memory>
#include <climits>

#include <QObject>
#include <QByteArray>
#include <QTimer>
#include <QVector>

#include <SerialDevice.h>

namespace strata {

class BaseDeviceCommand;

/*!
 * The DeviceOperation enum for DeviceOperations::finished() signal.
 */
enum class DeviceOperation: int {
    None,
    Identify,
    SwitchToBootloader,
    FlashFirmwareChunk,
    BackupFirmwareChunk,
    StartApplication,
    RefreshPlatformId,
    // special values for finished signal:
    Cancel,
    Timeout
};

class DeviceOperations : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(DeviceOperations)

public:
    /*!
     * DeviceOperations constructor.
     * \param device device which will be used by DeviceOperations
     */
    DeviceOperations(const SerialDevicePtr& device);

    /*!
     * DeviceOperations destructor.
     */
    ~DeviceOperations();

    /*!
     * Identify board operation.
     * \param requireFwInfoResponse true if response to 'get_firmware_info' command is required
     */
    void identify(bool requireFwInfoResponse = true);

    /*!
     * Switch To Bootloader operation.
     */
    void switchToBootloader();

    /*!
     * Flash Firmware Chunk operation.
     * \param chunk firmware chunk
     * \param chunkNumber firmware chunk number
     */
    void flashFirmwareChunk(const QVector<quint8>& chunk, int chunkNumber);

    /*!
     * Backup Firmware Chunk operation.
     */
    void backupFirmwareChunk();

    /*!
     * Start Application operation.
     */
    void startApplication();

    /*!
     * Refresh information about device (name, platform Id, class ID).
     */
    void refreshPlatformId();

    /*!
     * Cancel operation - terminate running operation.
     */
    void cancelOperation();

    /*!
     * Get ID of device used by DeviceOperations.
     * \return device ID
     */
    int deviceId() const;

    /*!
     * Get firmware chunk from last backupFirmwareChunk() operation.
     * \return firmware chunk from last backupFirmwareChunk() operation
     */
    QVector<quint8> recentBackupChunk() const;

    friend QDebug operator<<(QDebug dbg, const DeviceOperations* devOp);

signals:
    /*!
     * This signal is emitted when DeviceOperations finishes.
     * \param operation value from DeviceOperation enum (opertion identificator or special value, e.g. Timeout)
     * \param data data related to finished operation (INT_MIN by default)
     */
    void finished(DeviceOperation operation, int data = INT_MIN);

    /*!
     * This signal is emitted when error occurres.
     * \param errorString error description
     */
    void error(QString errorString);

    // signal only for internal use:
    // Qt5 private signals: https://woboq.com/blog/how-qt-signals-slots-work-part2-qt5.html
    void sendCommand(QPrivateSignal);

private slots:
    void handleSendCommand();
    void handleDeviceResponse(const QByteArray& data);
    void handleResponseTimeout();
    void handleSerialDeviceError(SerialDevice::ErrorCode errCode, QString msg);

private:
    bool startOperation(DeviceOperation operation);
    void nextCommand();
    void finishOperation(DeviceOperation operation, int data = INT_MIN);
    void reset();

    SerialDevicePtr device_;
    uint deviceId_;

    QTimer responseTimer_;

    DeviceOperation operation_;

    std::vector<std::unique_ptr<BaseDeviceCommand>> commandList_;
    std::vector<std::unique_ptr<BaseDeviceCommand>>::iterator currentCommand_;

    QVector<quint8> backupChunk_;
};

}  // namespace

#endif
