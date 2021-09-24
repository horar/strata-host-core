/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef COMMANDS_H
#define COMMANDS_H

#include <Operations/Identify.h>
#include <memory>
#include <QObject>
#include <QString>

namespace strata {

class Command : public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(Command)

public:
    Command();
    virtual ~Command();
    virtual void process() = 0;

signals:
    void finished(int returnCode);
};

class WrongCommand : public Command {
    Q_OBJECT
    Q_DISABLE_COPY(WrongCommand)

public:
    WrongCommand(const QString &message);
    void process() override;

private:
    const QString message_;
};

class HelpCommand : public Command {
    Q_OBJECT
    Q_DISABLE_COPY(HelpCommand)

public:
    HelpCommand(const QString &helpText);
    void process() override;

private:
    const QString helpText_;
};

class VersionCommand : public Command {
    Q_OBJECT
    Q_DISABLE_COPY(VersionCommand)

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
    Q_DISABLE_COPY(ListCommand)

public:
    ListCommand();
    void process() override;
};

class DeviceCommand : public Command {
    Q_OBJECT
    Q_DISABLE_COPY(DeviceCommand)

public:
    explicit DeviceCommand(int deviceNumber);
    virtual ~DeviceCommand() override;

signals:
    void criticalDeviceError();

protected slots:
    virtual void handlePlatformOpened() = 0;
    void handleDeviceError(device::Device::ErrorCode errCode, QString errStr);

protected:
    bool createSerialDevice();

    const int deviceNumber_;
    unsigned int openCount_;
    platform::PlatformPtr platform_;
};

class Flasher;

class FlasherCommand : public DeviceCommand {
    Q_OBJECT
    Q_DISABLE_COPY(FlasherCommand)

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
    virtual void handlePlatformOpened() override;
    void handleCriticalDeviceError();

private:
    std::unique_ptr<Flasher> flasher_;
    const QString fileName_;
    const CmdType command_;
};

class InfoCommand : public DeviceCommand {
    Q_OBJECT
    Q_DISABLE_COPY(InfoCommand)

public:
    explicit InfoCommand(int deviceNumber);
    ~InfoCommand() override;
    void process() override;

private slots:
    virtual void handlePlatformOpened() override;
    void handleIdentifyOperationFinished(platform::operation::Result result, int status, QString errStr);
    void handleCriticalDeviceError();

private:
    std::unique_ptr<platform::operation::Identify> identifyOperation_;
};

}  // namespace

#endif
