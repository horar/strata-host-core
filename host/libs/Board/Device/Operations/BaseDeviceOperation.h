#pragma once

#include <functional>

#include <QObject>
#include <QTimer>

#include <Device/Device.h>

#include <DeviceOperationsFinished.h>

namespace strata::device::command {

class BaseDeviceCommand;
enum class CommandResult : int;

}

namespace strata::device::operation {

/*!
 * The DeviceOperation enum for devide operation finished() signal.
 */
enum class Type: int {
    Identify,
    StartBootloader,
    FlashFirmware,
    FlashBootloader,
    BackupFirmware,
    StartApplication,
    SetPlatformId,
    SetAssistedPlatformId,
    // special values for finished signal (operation was not finished successfully):
    Cancel,   // operation was cancelled
    Timeout,  // no response from device
    Failure   // faulty response from device
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
     * Test if operation has already finished.
     * \return true if operation has finished, otherwise false
     */
    virtual bool isFinished() const final;

    /*!
     * Cancel operation - terminate running operation.
     */
    virtual void cancelOperation() final;

    /*!
     * Get ID of device used by device pperation.
     * \return device ID
     */
    virtual int deviceId() const final;

signals:
    /*!
     * This signal is emitted when device operation finishes.
     * \param operation value from OperationType enum (opertion identificator or special value, e.g. Timeout)
     * \param data data related to finished operation (OPERATION_DEFAULT_DATA (INT_MIN) by default)
     */
    void finished(Type operation, int data);

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

private:
    void nextCommand();
    void finishOperation(Type operation, int data = operation::DEFAULT_DATA);
    void reset();

    const Type type_;

    QTimer responseTimer_;

protected:
    void resume();

    device::DevicePtr device_;

    bool run_;
    bool finished_;

    std::vector<std::unique_ptr<command::BaseDeviceCommand>> commandList_;
    std::vector<std::unique_ptr<command::BaseDeviceCommand>>::iterator currentCommand_;

    std::function<void(command::CommandResult&, int&)> postCommandHandler_;

};

}  // namespace
