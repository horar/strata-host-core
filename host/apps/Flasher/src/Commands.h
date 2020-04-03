#ifndef COMMANDS_H
#define COMMANDS_H

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

class FlashCommand : public Command {
    Q_OBJECT
public:
    FlashCommand(const QString &fileName, int deviceNumber);
    ~FlashCommand() override;
    void process() override;
private slots:
    void flasherFinished(bool success);
private:
    std::unique_ptr<Flasher> flasher_;
    const QString fileName_;
    const int deviceNumber_;
};

}  // namespace

#endif
