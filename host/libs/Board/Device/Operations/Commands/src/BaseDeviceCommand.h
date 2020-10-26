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
    Failure,           // response to command is not successful
    FinaliseOperation  // finish operation (there is no point in continuing)
};

class BaseDeviceCommand {
public:
    /*!
     * BaseDeviceCommand constructor.
     * \param name command name
     * \param device the device on which the operation is performed
     */
    BaseDeviceCommand(const device::DevicePtr& device, const QString& name);

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
     * Sets ACK received flag.
     */
    virtual void setAckReceived() final;

    /*!
     * Checks if ACK received flag is set.
     * \return true if ACK received flag is set, otherwise false
     */
    virtual bool ackReceived() const final;

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
     * Returns specific data for finished() signal (e.g. chunk number).
     * \return data for finished() signal or INT_MIN if not used (by default)
     */
    virtual int dataForFinish() const;

    /*!
     * Command name.
     * \return name of command
     */
    virtual const QString name() const final;

    /*!
     * Command result.
     * \return result of command (value from CommandResult enum)
     */
    virtual CommandResult result() const final;

protected:
    virtual void setDeviceProperties(const char* name, const char* platformId, const char* classId, const char* btldrVer, const char* applVer) final;
    virtual void setDeviceBootloaderMode(bool inBootloaderMode) final;
    virtual void setDeviceApiVersion(device::Device::ApiVersion apiVersion) final;
    const QString cmdName_;
    const device::DevicePtr& device_;
    bool ackReceived_;
    CommandResult result_;
};

}  // namespace

#endif
