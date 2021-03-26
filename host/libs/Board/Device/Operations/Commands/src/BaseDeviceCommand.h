#ifndef BASE_DEVICE_COMMAND_H
#define BASE_DEVICE_COMMAND_H

#include <QByteArray>
#include <QString>
#include <QTimer>

#include <rapidjson/document.h>

#include <Device/Device.h>

namespace strata::device::command {

enum class CommandResult : int {
    Done,              // successfully done
    DoneAndWait,       // successfully done, move to next command but do not send it
    Repeat,            // successfully done, command is expected to be send again (with new data)
    Retry,             // retry - send command again with same data
    Reject,            // command was rejected (is unsupported)
    Failure,           // response to command is not successful
    FinaliseOperation, // finish operation (there is no point in continuing)
    Timeout,           // command has timed out
    Unsent,            // command was not sent (sending to device has failed)
    Cancel,            // command was cencelled
    DeviceError        // unexpected device error has occured
};

enum class CommandType : int {
    BackupFirmware,
    FlashBootloader,
    FlashFirmware,
    GetFirmwareInfo,
    RequestPlatformid,
    SetAssistedPlatformId,
    SetPlatformId,
    StartApplication,
    StartBackupFirmware,
    StartBootloader,
    StartFlashBootloader,
    StartFlashFirmware,
    Wait
};

class BaseDeviceCommand : public QObject
{
    Q_OBJECT

protected:
    /*!
     * BaseDeviceCommand constructor.
     * \param device the device on which is this command performed
     * \param name command name
     * \param cmdType type of command (value from CommandType enum)
     */
    BaseDeviceCommand(const DevicePtr& device, const QString& name, CommandType cmdType);

public:
    /*!
     * BaseDeviceCommand destructor.
     */
    virtual ~BaseDeviceCommand();

    // disable copy assignment operator
    BaseDeviceCommand & operator=(const BaseDeviceCommand&) = delete;

    // disable copy constructor
    BaseDeviceCommand(const BaseDeviceCommand&) = delete;

    /*!
     * Sends command to device.
     * \param lockId device lock ID
     */
    virtual void sendCommand(quintptr lockId);

    /*!
     * Cancel running command.
     */
    virtual void cancel();

    /*!
     * Command name.
     * \return name of command
     */
    virtual const QString name() const final;

    /*!
     * Command type.
     * \return type of command (value from CommandType enum)
     */
    virtual CommandType type() const final;

    /*!
     * Set command response timeout.
     * \param responseInterval command response timeout
     */
    virtual void setResponseTimeout(std::chrono::milliseconds responseInterval) final;

signals:
    /*!
     * Emitted when command is finished.
     * \param result value from CommandResult enum
     * \param status specific command return value
     */
    void finished(CommandResult result, int status);

protected:
    /*!
     * Returns JSON command.
     * \return message to be send to device
     */
    virtual QByteArray message() = 0;

    /*!
     * Process response (notification) from device.
     * \param doc JSON from notification
     * \param result comand result set by this method
     * \return true if notification is valid for sent command, otherwise false
     */
    virtual bool processNotification(rapidjson::Document& doc, CommandResult& result) = 0;

    /*!
     * This method is called when expires timeout for sent command.
     * \return value from CommandResult enum
     */
    virtual CommandResult onTimeout();

    /*!
     * This method is called when command is rejected by device.
     * \return value from CommandResult enum
     */
    virtual CommandResult onReject();

    /*!
     * Checks if information about sent message should be logged.
     * \return true if information about sent message should be logged, otherwise false
     */
    virtual bool logSendMessage() const;

private slots:
    void handleDeviceResponse(const QByteArray data);
    void handleResponseTimeout();
    void handleDeviceError(device::Device::ErrorCode errCode, QString errStr);

protected:
    virtual void setDeviceVersions(const char* bootloaderVer, const char* applicationVer) final;
    virtual void setDeviceProperties(const char* name, const char* platformId, const char* classId, Device::ControllerType type) final;
    virtual void setDeviceAssistedProperties(const char* platformId, const char* classId, const char* fwClassId) final;
    virtual void setDeviceBootloaderMode(bool inBootloaderMode) final;
    virtual void setDeviceApiVersion(Device::ApiVersion apiVersion) final;

    const QString cmdName_;
    const CommandType cmdType_;
    const DevicePtr& device_;
    bool ackOk_;
    int status_;

private:
    void finishCommand(CommandResult result);
    void logWrongResponse(const QByteArray& response);
    bool deviceSignalsConnected_;

    QTimer responseTimer_;
};

}  // namespace

#endif
