#ifndef FLASHER_CLI_H
#define FLASHER_CLI_H

#include <memory>

#include <QObject>
#include <QList>
#include <QString>

namespace strata {

class SerialPortList {
public:
    SerialPortList();
    QString getPortName(int index) const;
    QList<QString> getPortList() const;
    int getPortCount() const;
private:
    QList<QString> port_names_;
};

struct CliOptions {
    CliOptions();
    enum class Option {
        none,
        list,
        flash
    };
    Option option;
    QString file_name;
    int device_number;
};

class Flasher;

class FlasherCli : public QObject {
    Q_OBJECT

public:
    FlasherCli(const CliOptions& options);
    ~FlasherCli();

public slots:
    void run();

signals:
    void finished(int returnCode);

private slots:
    void handleFinish(bool success);

private:
    std::unique_ptr<Flasher> flasher_;
    const CliOptions options_;
};

}  // namespace

#endif
