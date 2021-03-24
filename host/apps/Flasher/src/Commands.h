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

class Flasher;

class FlasherCommand : public Command {
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
private:
    std::unique_ptr<Flasher> flasher_;
    const QString fileName_;
    const int deviceNumber_;
    const CmdType command_;
};

class InfoCommand : public Command {
    Q_OBJECT
public:
    InfoCommand(int deviceNumber);
    ~InfoCommand() override;
    void process() override;

private slots:
    virtual void handleIdentifyOperationFinished(device::operation::Result result, int status, QString errStr);

private:
    const int deviceNumber_;
    device::DevicePtr device_;
    std::unique_ptr<device::operation::Identify> identifyOperation_;
};

}  // namespace

#endif
