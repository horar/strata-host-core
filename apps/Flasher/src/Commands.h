#ifndef COMMANDS_H
#define COMMANDS_H

#include <Operations/Identify.h>
#include <memory>
#include <QObject>
#include <QString>

namespace strata {

class Command : public QObject {
    Q_OBJECT
public:
    virtual ~Command();
    virtual void process() = 0;
signals:
    void finished(int returnCode);
};

class WrongCommand : public Command {
    Q_OBJECT
public:
    WrongCommand(const QString &message);
    void process() override;
private:
    const QString message_;
};

class HelpCommand : public Command {
    Q_OBJECT
public:
    HelpCommand(const QString &helpText);
    void process() override;
private:
    const QString helpText_;
};

class VersionCommand : public Command {
    Q_OBJECT
public:
    VersionCommand(const QString &appName, const QString &appDescription, const QString &appVersion);
    void process() override;
private:
    const QString appName_;
    const QString appDescription_;
    const QString appVersion_;
};

class ListCommand : public Command {
    Q_OBJECT
public:
    void process() override;
};

class DeviceCommand : public Command {
    Q_OBJECT
public:
    explicit DeviceCommand(int deviceNumber);
    virtual ~DeviceCommand() override;

protected slots:
    virtual void handlePlatformOpened(QByteArray deviceId) = 0;
    virtual void handleDeviceError(QByteArray deviceId, device::Device::ErrorCode errCode, QString errStr);

protected:
    bool createSerialDevice();

    const int deviceNumber_;
    unsigned int openRetries_;
    platform::PlatformPtr platform_;
};

class Flasher;

class FlasherCommand : public DeviceCommand {
    Q_OBJECT
public:
    enum class CmdType {
        FlashFirmware,
        FlashBootloader,
        BackupFirmware
    };
    FlasherCommand(const QString &fileName, int deviceNumber, CmdType command);
    ~FlasherCommand() override;
    void process() override;

private slots:
    virtual void handlePlatformOpened(QByteArray deviceId) override;

private:
    std::unique_ptr<Flasher> flasher_;
    const QString fileName_;
    const CmdType command_;
};

class InfoCommand : public DeviceCommand {
    Q_OBJECT
public:
    explicit InfoCommand(int deviceNumber);
    ~InfoCommand() override;
    void process() override;

private slots:
    virtual void handlePlatformOpened(QByteArray deviceId) override;
    virtual void handleIdentifyOperationFinished(platform::operation::Result result, int status, QString errStr);

private:
    std::unique_ptr<platform::operation::Identify> identifyOperation_;
};

}  // namespace

#endif
