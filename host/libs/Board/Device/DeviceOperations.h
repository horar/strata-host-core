#ifndef DEVICE_OPERATIONS_H
#define DEVICE_OPERATIONS_H

#include <vector>
#include <memory>

#include <QObject>
#include <QByteArray>
#include <QTimer>
#include <QVector>

#include <Device/Device.h>

#include <DeviceOperationsFinished.h>

namespace strata::device::command {

class BaseDeviceCommand;

}

namespace strata::device {

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
    // special values for finished signal (operation was not finished successfully):
    Cancel,   // operation was cancelled
    Timeout,  // no response from device
    Failure   // faulty response from device
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
    DeviceOperations(const device::DevicePtr& device);

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

signals:
    /*!
     * This signal is emitted when DeviceOperations finishes.
     * \param operation value from DeviceOperation enum (opertion identificator or special value, e.g. Timeout)
     * \param data data related to finished operation (INT_MIN by default)
     */
    void finished(DeviceOperation operation, int data = OPERATION_DEFAULT_DATA);

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
    void handleDeviceError(device::Device::ErrorCode errCode, QString msg);

protected:
    bool startOperation(DeviceOperation operation);
    void nextCommand();
    void finishOperation(DeviceOperation operation, int data = OPERATION_DEFAULT_DATA);
    void reset();

    device::DevicePtr device_;
    uint deviceId_;

    QTimer responseTimer_;

    DeviceOperation operation_;

    std::vector<std::unique_ptr<command::BaseDeviceCommand>> commandList_;
    std::vector<std::unique_ptr<command::BaseDeviceCommand>>::iterator currentCommand_;

    QVector<quint8> backupChunk_;
};

}  // namespace

#endif
