#ifndef DEVICE_COMMANDS_H
#define DEVICE_COMMANDS_H

#include <chrono>

#include <QByteArray>
#include <QString>
#include <QVector>

#include <rapidjson/document.h>

#include <SerialDevice.h>

namespace strata {

enum class CommandResult {
    InProgress,        // waiting for proper response from device
    Done,              // successfully done (received device response is OK)
    Repeat,            // repeat - send command again again with new data, e.g. when flashing firmware
    Retry,             // retry - send command again with same data
    FinaliseOperation  // finish operation (there is no point in continuing)
};

class BaseDeviceCommand {
public:
    /*!
     * BaseDeviceCommand constructor.
     * \param name command name
     * \param device the device on which the operation is performed
     */
    BaseDeviceCommand(const SerialDevicePtr& device, const QString& name);

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
     * Checks if command should be sent or skipped.
     * \return true if command should be skipped, otherwise false
     */
    virtual bool skip();

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
     * Prepare command for repeat (sending again).
     */
    virtual void prepareRepeat();

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
    const QString cmdName_;
    const SerialDevicePtr& device_;
    bool ackReceived_;
    CommandResult result_;
};

class CmdGetFirmwareInfo : public BaseDeviceCommand {
public:
    CmdGetFirmwareInfo(const SerialDevicePtr& device, bool requireResponse);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
    void onTimeout() override;
private:
    bool requireResponse_;
};

class CmdRequestPlatformId : public BaseDeviceCommand {
public:
    CmdRequestPlatformId(const SerialDevicePtr& device);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
};

class CmdUpdateFirmware : public BaseDeviceCommand {
public:
    CmdUpdateFirmware(const SerialDevicePtr& device);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
    bool skip() override;
    std::chrono::milliseconds waitBeforeNextCommand() const override;
    int dataForFinish() const override;
};

class CmdFlashFirmware : public BaseDeviceCommand {
public:
    CmdFlashFirmware(const SerialDevicePtr& device);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
    bool logSendMessage() const override;
    void prepareRepeat() override;
    int dataForFinish() const override;
    void setChunk(const QVector<quint8>& chunk, int chunkNumber);
private:
    QVector<quint8> chunk_;
    int chunkNumber_;
    const uint maxRetries_;
    uint retriesCount_;
};

class CmdBackupFirmware : public BaseDeviceCommand {
public:
    CmdBackupFirmware(const SerialDevicePtr& device, QVector<quint8>& chunk);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
    bool logSendMessage() const override;
    void prepareRepeat() override;
    int dataForFinish() const override;
    QVector<quint8> chunk() const;
private:
    QVector<quint8>& chunk_;
    int chunkNumber_;
    bool firstBackupChunk_;
    const uint maxRetries_;
    uint retriesCount_;
};

class CmdStartApplication : public BaseDeviceCommand {
public:
    CmdStartApplication(const SerialDevicePtr& device);
    QByteArray message() override;
    bool processNotification(rapidjson::Document& doc) override;
};

}  // namespace

#endif
