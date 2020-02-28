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
private:
    QList<QString> portNames_;
};

class Flasher;

class FlasherCli : public QObject {
    Q_OBJECT

public:
    FlasherCli();
    ~FlasherCli();

public slots:
    void run();

signals:
    void finished(int returnCode);

private slots:
    void handleFinish(bool success);

private:
    std::unique_ptr<Flasher> flasher_;

};

}  // namespace

#endif
