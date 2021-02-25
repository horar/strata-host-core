#ifndef BASE_DEVICE_COMMAND_H
#define BASE_DEVICE_COMMAND_H

#include <chrono>

#include <QByteArray>
#include <QString>

#include <rapidjson/document.h>

#include <Device/Device.h>

namespace strata::device::command {

enum class CommandResult : int {
    InProgress,        // waiting for proper response from device
    Done,              // successfully done (received device response is OK)
    Partial,           // successfully done (received device response is OK), another command is expected to follow
    Retry,             // retry - send command again with same data
    Reject,            // command was rejected (is unsupported)
    Failure,           // response to command is not successful
    FinaliseOperation  // finish operation (there is no point in continuing)
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
    StartFlashFirmware
};

class BaseDeviceCommand {
public:
    /*!
     * BaseDeviceCommand constructor.
     * \param name command name
     * \param device the device on which the operation is performed
     */
    BaseDeviceCommand(const DevicePtr& device, const QString& name, CommandType cmdType);

    /*!
     * BaseDeviceCommand destructor.
     */
    virtual ~BaseDeviceCommand();

    // disable copy assignment operator
    BaseDeviceCommand & operator=(const BaseDeviceCommand&) = delete;

    // disable copy constructor
    BaseDeviceCommand(const BaseDeviceCommand&) = delete;

    /*!
     * Returns JSON command.
     * \return message to be send to device
     */
    virtual QByteArray message() = 0;

    /*!
     * Process response (notification) from device.
     * \param doc JSON from notification
     * \return true if notification is valid for sent command, otherwise false
     */
    virtual bool processNotification(rapidjson::Document& doc) = 0;

    /*!
     * Sets ACK OK flag.
     */
    virtual void commandAcknowledged() final;

    /*!
     * Checks if ACK OK flag is set.
     * \return true if ACK OK flag is set, otherwise false
     */
    virtual bool isCommandAcknowledged() const final;

    /*!
     * Sets command result to CommandResult::Reject.
     */
    virtual void commandRejected();

    /*!
     * This method is called when expires timeout for sent command.
     */
    virtual void onTimeout();

    /*!
     * Checks if information about sent message should be logged.
     * \return true if information about sent message should be logged, otherwise false
     */
    virtual bool logSendMessage() const;

    /*!
     * Returns how long to wait before sending next command.
     * \return number of milliseconds
     */
    virtual std::chrono::milliseconds waitBeforeNextCommand() const;

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
     * Command result.
     * \return result of command (value from CommandResult enum)
     */
    virtual CommandResult result() const final;

    /*!
     * Command status.
     * \return status specific for command (chunk number, defined constant, ...)
     */
    virtual int status() const final;

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
    CommandResult result_;
    int status_;
};

}  // namespace

#endif
