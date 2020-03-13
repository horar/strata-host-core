#include <cstdlib>
#include <iostream>

#include <QSerialPortInfo>

#include <SerialDevice.h>
#include <Flasher.h>
#include "FlasherCli.h"

#include "logging/LoggingQtCategories.h"

namespace strata {

SerialPortList::SerialPortList() {
#if defined(Q_OS_MACOS)
    const QString usb_keyword("usb");
    const QString cu_keyword("cu");
#elif defined(Q_OS_LINUX)
    // TODO: this code was not tested on Linux, test it
    const QString usb_keyword("USB");
#elif defined(Q_OS_WIN)
    const QString usb_keyword("COM");
#endif

    const auto allPorts = QSerialPortInfo::availablePorts();
    for (const QSerialPortInfo& serialPortInfo : allPorts) {
        const QString& name = serialPortInfo.portName();
        if (serialPortInfo.isNull()) {
            continue;
        }
        if (name.contains(usb_keyword) == false) {
            continue;
        }
#ifdef Q_OS_MACOS
        if (name.startsWith(cu_keyword) == false) {
            continue;
        }
#endif
        port_names_.append(name);
    }
}

QString SerialPortList::getPortName(int index) const {
    return port_names_.value(index);
}

QList<QString> SerialPortList::getPortList() const {
    return port_names_;
}

int SerialPortList::getPortCount() const {
    return port_names_.count();
}

CliOptions::CliOptions() : option(Option::none), device_number(1) { }

FlasherCli::FlasherCli(const CliOptions& options) : options_(options) { }

FlasherCli::~FlasherCli() { }

void FlasherCli::run() {
    strata::SerialPortList portList;

    if (options_.option == CliOptions::Option::list) {
        auto const list = portList.getPortList();
        if (list.isEmpty()) {
            std::cout << "No board is conected." << std::endl;
        } else {
            std::cout << "List of available boards (serial devices):" << std::endl;
            for (int i = 0; i < list.size(); ++i) {
                std::cout << i+1 << ". " << list.at(i).toStdString() << std::endl;
            }
        }
        emit finished(EXIT_SUCCESS);
        return;
    }

    if (options_.option == CliOptions::Option::flash) {
        if (portList.getPortCount() == 0) {
            qCWarning(logCategoryFlasherCli) << "No board is connected.";
            emit finished(EXIT_FAILURE);
            return;
        }

        QString name = portList.getPortName(options_.device_number - 1);
        if (name.isEmpty()) {
            qCWarning(logCategoryFlasherCli) << "Board number" << options_.device_number << "is not available.";
            emit finished(EXIT_FAILURE);
            return;
        }

        auto device = std::make_shared<SerialDevice>(static_cast<int>(qHash(name)), name);
        if (device->open() == false) {
            qCWarning(logCategoryFlasherCli) << "Cannot open board (serial device)" << name;
            emit finished(EXIT_FAILURE);
            return;
        }

        flasher_ = std::make_unique<Flasher>(device, options_.file_name);

        connect(flasher_.get(), &Flasher::finished, this, &FlasherCli::handleFinish);

        flasher_->flash();

        return;
    }

    qCWarning(logCategoryFlasherCli) << "Unsupported option";
    emit finished(EXIT_FAILURE);
}

void FlasherCli::handleFinish(bool success) {
    emit finished((success) ? EXIT_SUCCESS : EXIT_FAILURE);
}

}  // namespace
