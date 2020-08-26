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
    StartFlashFirmware,
    StartFlashBootloader,
    FlashFirmwareChunk,
    FlashBootloaderChunk,
    StartBackupFirmware,
    BackupFirmwareChunk,
    StartApplication,
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
     * Identify board operation - get information about device (name, platform Id, class ID, bootloader/application version).
     * \param requireFwInfoResponse true if response to 'get_firmware_info' command is required
     */
    void identify(bool requireFwInfoResponse = true);

    /*!
     * Switch To Bootloader operation.
     */
    void switchToBootloader();

    /*!
     * Start Flash Firmware operation
     * \param size firmware size (in bytes)
     * \param chunks number of firmware chunks (which will be flashed)
     * \param md5 MD5 checksum of firmware
     */
    void startFlashFirmware(uint size, uint chunks, const QString& md5);

    /*!
     * Flash Firmware Chunk operation.
     * \param chunk firmware chunk
     * \param chunkNumber firmware chunk number (from 0 to N-1)
     * \param chunkCount total count of firmware chunks (N)
     */
    void flashFirmwareChunk(const QVector<quint8>& chunk, int chunkNumber, int chunkCount);

    /*!
     * Start Backup Firmware operation
     */
    void startBackupFirmware();

    /*!
     * Backup Firmware Chunk operation.
     * \param chunkCount total count of firmware chunks
     */
    void backupFirmwareChunk(int chunkCount);

    /*!
     * Start Flash Bootloader operation
     * \param size bootloader size (in bytes)
     * \param chunks number of bootloader chunks (which will be flashed)
     * \param md5 MD5 checksum of bootloader
     */
    void startFlashBootloader(uint size, uint chunks, const QString& md5);

    /*!
     * Flash Bootloader Chunk operation.
     * \param chunk bootloader chunk
     * \param chunkNumber bootloader chunk number (from 0 to N-1)
     * \param chunkCount total count of bootloader chunks (N)
     */
    void flashBootloaderChunk(const QVector<quint8>& chunk, int chunkNumber, int chunkCount);

    /*!
     * Start Application operation.
     */
    void startApplication();

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

    /*!
     * Get total count of chunks of backed up firmware.
     * \return count of backed up firmware chunks
     */
    int backupChunksCount() const;

    /*!
     * Set size and MD5 checksum of flashed firmware (or bootloader). This method must
     * be called before first call of flashFirmwareChunk or flashBootloaderChunk
     * \param fileSize size of firmware (or bootloader) in bytes
     * \param fileMD5 MD5 checksum of firmware (or bootloader)
     */
    void setFlashInfo(qint64 fileSize, const QString& fileMD5);

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
    DeviceOperation operation_;

private:
    bool startOperation(DeviceOperation operation);
    void nextCommand();
    void finishOperation(DeviceOperation operation, int data = OPERATION_DEFAULT_DATA);
    void reset();

    void startFlash(uint size, uint chunks, const QString& md5, bool flashFirmware);
    void flashChunk(const QVector<quint8>& chunk, int chunkNumber, int chunkCount, bool flashFirmware);

    device::DevicePtr device_;
    uint deviceId_;

    QTimer responseTimer_;

    std::vector<std::unique_ptr<command::BaseDeviceCommand>> commandList_;
    std::vector<std::unique_ptr<command::BaseDeviceCommand>>::iterator currentCommand_;

    QVector<quint8> backupChunk_;
    int backupChunksCount_;
    qint64 fileSize_;
    QString fileMD5_;
};

}  // namespace

#endif
