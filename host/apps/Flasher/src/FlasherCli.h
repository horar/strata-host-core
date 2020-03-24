#ifndef FLASHER_CLI_H
#define FLASHER_CLI_H

#include <memory>

#include <QObject>
#include <QList>
#include <QString>

namespace strata {

class SerialPortList {
public:
    /*!
     * SerialPortList constructor.
     */
    SerialPortList();

    /*!
     * Get name of serial port.
     * \param index index of serial port (starting from 0)
     * \return name of serial port if index is valid, otherwise empty string
     */
    QString getPortName(int index) const;

    /*!
     * Get list of available serial ports.
     * \return list of names of all available serial ports
     */
    QList<QString> getPortList() const;

    /*!
     * Get count of available serial ports.
     * \return count of available serial ports
     */
    int getPortCount() const;

private:
    QList<QString> portNames_;
};

struct CliOptions {
    CliOptions();
    enum class Option {
        none,
        list,
        flash
    };
    Option option;
    QString fileName;
    int deviceNumber;
};

class Flasher;

class FlasherCli : public QObject {
    Q_OBJECT

public:
    /*!
     * FlasherCli constructor.
     * \param options struct CliOptions filled with options from command line
     */
    FlasherCli(const CliOptions& options);

    ~FlasherCli();

public slots:
    /*!
     * Starts the flasher.
     */
    void run();

signals:
    /*!
     * This signal is emitted when FlasherCli finishes.
     * \param returnCode flasher application return code
     */
    void finished(int returnCode);

private slots:
    void handleFinish(bool success);

private:
    std::unique_ptr<Flasher> flasher_;
    const CliOptions options_;
};

}  // namespace

#endif
