/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QByteArray>
#include <QString>
#include <QTimer>

#include <rapidjson/document.h>

#include <Platform.h>

namespace strata::platform::command {

enum class CommandResult : int {
    Done,               // command done, move to next command and send it
    DoneAndWait,        // command done, move to next command but do not send it yet
    RepeatAndWait,      // command is expected to be send again (with new data), do not send it yet
    Retry,              // retry - send command again with same data
    Reject,             // command was rejected (is unsupported)
    Failure,            // failure - response to command is not successful
    FinaliseOperation,  // finish operation (there is no point in continuing)
    Timeout,            // command has timed out
    MissingAck,         // failure - received notification without previous ACK
    Unsent,             // command was not sent (sending to device has failed)
    Cancel,             // command was cencelled
    DeviceDisconnected, // device unexpectedly disconnected (unplugged)
    DeviceError         // unexpected device error has occured
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

class BasePlatformCommand : public QObject
{
    Q_OBJECT

protected:
    /*!
     * BasePlatformCommand constructor.
     * \param platform the platform on which is this command performed
     * \param name command name
     * \param cmdType type of command (value from CommandType enum)
     */
    BasePlatformCommand(const PlatformPtr& platform, const QString& name, CommandType cmdType);

public:
    /*!
     * BasePlatformCommand destructor.
     */
    virtual ~BasePlatformCommand();

    // disable copy assignment operator
    BasePlatformCommand & operator=(const BasePlatformCommand&) = delete;

    // disable copy constructor
    BasePlatformCommand(const BasePlatformCommand&) = delete;

    /*!
     * Sends command to platform.
     * \param lockId platform lock ID
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
     * Set response timeout for command ACK.
     * \param ackTimeout command ACK response timeout
     */
    virtual void setAckTimeout(std::chrono::milliseconds ackTimeout) final;

    /*!
     * Set response timeout for command notification. This timeout starts after receiving ACK.
     * \param notificationTimeout command notification response timeout
     */
    virtual void setNotificationTimeout(std::chrono::milliseconds notificationTimeout) final;

    /*!
     * Turn on/off 'validationFailure' and 'processedNotification' signals during
     * processing messages from platform. By default these signals are turned off.
     * Also turns on more strict check for command ACK.
     * \param enabled true for turn on platform validation, false for turn off
     */
    virtual void enablePlatformValidation(bool enable) final;

signals:
    /*!
     * Emitted when command is finished.
     * \param result value from CommandResult enum
     * \param status specific command return value
     */
    void finished(CommandResult result, int status);

    /*!
     * Emitted when some issue occurs during processing message from device.
     * This signal is emitted only if it was enabled by 'setValidationSignals' method.
     * \param error description of what goes wrong during message processing
     * \param fatal if set to 'true' failure was fatal - validation cannot be succesful anymore
     */
    void validationFailure(QString error, bool fatal);

    /*!
     * Emitted when notification from platfom was received.
     * This signal is emitted only if it was enabled by 'setValidationSignals' method.
     * \param message received notification from platform
     */
    void receivedNotification(PlatformMessage message);

protected:
    /*!
     * Returns JSON command.
     * \return message to be send to platform
     */
    virtual QByteArray message() = 0;

    /*!
     * Process response (notification) from platform.
     * \param doc JSON from notification
     * \param result comand result set by this method
     * \return true if notification is valid for sent command, otherwise false
     */
    virtual bool processNotification(const rapidjson::Document& doc, CommandResult& result) = 0;

    /*!
     * This method is called when expires timeout for sent command.
     * \return value from CommandResult enum
     */
    virtual CommandResult onTimeout();

    /*!
     * This method is called when command is rejected by platform.
     * \return value from CommandResult enum
     */
    virtual CommandResult onReject();

    /*!
     * Checks if information about sent message should be logged.
     * \return true if information about sent message should be logged, otherwise false
     */
    virtual bool logSendMessage() const;

private slots:
    void handleDeviceResponse(const PlatformMessage message);
    void handleResponseTimeout();
    void handleMessageSent(QByteArray rawMessage, unsigned msgNumber, QString errStr);

protected slots:
    void handleDeviceError(device::Device::ErrorCode errCode, QString errStr);

protected:
    virtual void setDeviceVersions(const char* bootloaderVer, const char* applicationVer) final;
    virtual void setDeviceProperties(const char* name, const char* platformId, const char* classId, Platform::ControllerType type) final;
    virtual void setDeviceAssistedProperties(const char* platformId, const char* classId, const char* fwClassId) final;
    virtual void setDeviceBootloaderMode(bool inBootloaderMode) final;
    virtual void setDeviceApiVersion(Platform::ApiVersion apiVersion) final;

    const QString cmdName_;
    const CommandType cmdType_;
    const PlatformPtr& platform_;
    QTimer responseTimer_;
    unsigned lastMsgNumber_;
    bool ackOk_;
    int status_;

private:
    void finishCommand(CommandResult result);
    QString generateWrongResponseError(const PlatformMessage& response) const;
    inline void emitValidationFailure(QString warning, bool fatal);
    std::chrono::milliseconds ackTimeout_;
    std::chrono::milliseconds notificationTimeout_;
    bool deviceSignalsConnected_;
    bool platformValidation_;

};

}  // namespace
