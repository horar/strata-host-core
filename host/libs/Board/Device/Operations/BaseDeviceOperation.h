#pragma once

#include <functional>

#include <QObject>
#include <QTimer>

#include <Device/Device.h>

namespace strata::device::command {

class BaseDeviceCommand;
enum class CommandResult : int;

}

namespace strata::device::operation {

enum class Type: int {
    Identify,
    StartBootloader,
    FlashFirmware,
    FlashBootloader,
    BackupFirmware,
    StartApplication,
    SetPlatformId,
    SetAssistedPlatformId
};

enum class Result: int {
    Success,  // successfully done
    Reject,   // some command from operation is not supported by device
    Cancel,   // operation was cancelled
    Timeout,  // no response from device
    Failure,  // faulty response from device
    Error     // error during operation
};

class BaseDeviceOperation : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(BaseDeviceOperation)

protected:
    /*!
     * BaseDeviceOperation constructor.
     * \param device device which will be used by device operation
     * \param type type of operation (value from OperationType enum)
     */
    BaseDeviceOperation(const device::DevicePtr& device, Type type);

public:
    /*!
     * BaseDeviceOperation destructor.
     */
    virtual ~BaseDeviceOperation();

    /*!
     * Run operation.
     */
    virtual void run();

    /*!
     * Test if operation has already started.
     * \return true if operation has started, otherwise false
     */
    virtual bool hasStarted() const final;

    /*!
     * Test if operation is already successfully finished.
     * \return true if operation is successfully finished, otherwise false
     */
    virtual bool isSuccessfullyFinished() const final;

    /*!
     * Test if operation is already finished.
     * \return true if operation is finished, otherwise false
     */
    virtual bool isFinished() const final;

    /*!
     * Cancel operation - terminate running operation.
     */
    virtual void cancelOperation() final;

    /*!
     * Get ID of device used by device operation.
     * \return device ID
     */
    virtual int deviceId() const final;

    /*!
     * Get type of operation.
     * \return operation type (value from enum Type)
     */
    virtual Type type() const final;

    /*!
     * Get error string for provided Result.
     * \param result enum value
     * \return corresponding error string
     */
     static QString resolveErrorString(Result result);

     void setResponseTimeout(std::chrono::milliseconds responseInterval);

protected:
    /*!
     * Check if device is in bootloader mode. Commands get_firmware_info
     * and request_platform_id must be called before calling this method.
     * \return true if device is in bootloader mode, otherwise false
     */
    virtual bool bootloaderMode() final;

signals:
    /*!
     * This signal is emitted when device operation finishes.
     * \param result value from Result enum
     * \param status specific status for operation
     * \param errorString error string (valid only if operation finishes with error)
     */
    void finished(Result result, int status, QString errorString = QString());

    // signal only for internal use:
    // Qt5 private signals: https://woboq.com/blog/how-qt-signals-slots-work-part2-qt5.html
    void sendCommand(QPrivateSignal);

private slots:
    void handleSendCommand();
    void handleDeviceResponse(const QByteArray data);
    void handleResponseTimeout();
    void handleDeviceError(device::Device::ErrorCode errCode, QString errStr);

private:
    void nextCommand();
    void reset();

    const Type type_;

    QTimer responseTimer_;

    bool started_;
    bool succeeded_;
    bool finished_;

protected:
    void finishOperation(Result result, const QString &errorString=QString());
    void resume();

    device::DevicePtr device_;

    // Every operation can have specific status when it finishes.
    int status_;

    std::vector<std::unique_ptr<command::BaseDeviceCommand>> commandList_;
    std::vector<std::unique_ptr<command::BaseDeviceCommand>>::iterator currentCommand_;

    std::function<void(command::CommandResult&, int&)> postCommandHandler_;

};

}  // namespace
