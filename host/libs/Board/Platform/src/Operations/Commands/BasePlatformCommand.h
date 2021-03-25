#pragma once

#include <QByteArray>
#include <QString>

#include <rapidjson/document.h>

#include <Device.h>

namespace strata::platform::command {

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
    StartFlashFirmware,
    Wait
};

class BasePlatformCommand {
public:
    /*!
     * BasePlatformCommand constructor.
     * \param name command name
     * \param device the device on which the operation is performed
     */
    BasePlatformCommand(const device::DevicePtr& device, const QString& name, CommandType cmdType);

    /*!
     * BasePlatformCommand destructor.
     */
    virtual ~BasePlatformCommand();

    // disable copy assignment operator
    BasePlatformCommand & operator=(const BasePlatformCommand&) = delete;

    // disable copy constructor
    BasePlatformCommand(const BasePlatformCommand&) = delete;

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
    virtual void setDeviceProperties(const char* name, const char* platformId, const char* classId, device::Device::ControllerType type) final;
    virtual void setDeviceAssistedProperties(const char* platformId, const char* classId, const char* fwClassId) final;
    virtual void setDeviceBootloaderMode(bool inBootloaderMode) final;
    virtual void setDeviceApiVersion(device::Device::ApiVersion apiVersion) final;
    const QString cmdName_;
    const CommandType cmdType_;
    const device::DevicePtr& device_;
    bool ackOk_;
    CommandResult result_;
    int status_;
};

}  // namespace
