/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <functional>

#include <QObject>
#include <QTimer>

#include <Platform.h>

namespace strata::platform::command {

class BasePlatformCommand;
enum class CommandResult : int;

}

namespace strata::platform::operation {

Q_NAMESPACE

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
Q_ENUM_NS(Type)

enum class Result: int {
    Success,    // successfully done
    Reject,     // some command from operation is not supported by device
    Cancel,     // operation was cancelled
    Timeout,    // no response from device
    Failure,    // faulty response from device
    Disconnect, // device disconnected during operation
    Error       // error during operation
};
Q_ENUM_NS(Result)

class BasePlatformOperation : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(BasePlatformOperation)

protected:
    /*!
     * BasePlatformOperation constructor.
     * \param platform platform which will be used by platform operation
     * \param type type of operation (value from Type enum)
     */
    BasePlatformOperation(const PlatformPtr& platform, Type type);

public:
    /*!
     * BasePlatformOperation destructor.
     */
    virtual ~BasePlatformOperation();

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
     * Get ID of device used by platform operation.
     * \return device ID
     */
    virtual QByteArray deviceId() const final;

    /*!
     * Get type of operation.
     * \return operation type (value from enum Type)
     */
    virtual Type type() const final;

#ifdef BUILD_TESTING
    /*!
     * Set same response timeouts (ACK + notification) for all commands in operation.
     * This method is used only in unit tests, DO NOT abuse it for other purposes!
     * \param responseInterval command response timeout
     */
    void setResponseTimeouts(std::chrono::milliseconds responseTimeout);
#endif

protected:
    /*!
     * Check if platform is in bootloader mode. Commands get_firmware_info
     * and request_platform_id must be called before calling this method.
     * \return true if platform is in bootloader mode, otherwise false
     */
    virtual bool bootloaderMode() final;

signals:
    /*!
     * This signal is emitted when platform operation finishes.
     * \param result value from Result enum
     * \param status specific status for operation
     * \param errorString error string (valid only if operation finishes with error)
     */
    void finished(Result result, int status, QString errorString = QString());

    /*!
     * This signal is emitted during some operations (e.g. firmware flashing) when one of
     * operation commands is done and its status is needed for caller of operation.
     * \param status partial operation status
     */
    void partialStatus(int status);

    // signal only for internal use:
    // Qt5 private signals: https://woboq.com/blog/how-qt-signals-slots-work-part2-qt5.html
    void sendCommand(QPrivateSignal);

private slots:
    void handleSendCommand();
    void handleCommandFinished(command::CommandResult result, int status);

private:
    const Type type_;

    bool started_;
    bool succeeded_;
    bool finished_;

protected:
    void initCommandList();
    void finishOperation(Result result, const QString &errorString);
    void resume();
    void setPlatformRecognized(bool isRecognozed);

    PlatformPtr platform_;

    // Every operation can have specific status when it finishes.
    int status_;

    std::vector<std::unique_ptr<command::BasePlatformCommand>> commandList_;
    std::vector<std::unique_ptr<command::BasePlatformCommand>>::iterator currentCommand_;

    std::function<void(command::CommandResult&, int&)> postCommandHandler_;
    std::function<void(Result)> postOperationHandler_;

};

}  // namespace
