#include <cstdlib>

#include <QSerialPortInfo>

#include <SerialDevice.h>
#include <Flasher.h>
#include "flasher_cli.h"

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
        portNames_.append(name);
    }
}

QString SerialPortList::getPortName(int index) const {
    return portNames_.value(index);
}

QList<QString> SerialPortList::getPortList() const {
    return portNames_;
}

FlasherCli::FlasherCli() { }

FlasherCli::~FlasherCli() { }

void FlasherCli::run() {

    strata::SerialPortList portList;
    QString name = portList.getPortName(0);

    if (name.isEmpty()) {
        qCInfo(logCategoryFlasherCli) << "No board";
        emit finished(EXIT_SUCCESS);
        return;
    }

    qCInfo(logCategoryFlasherCli) << name;
    auto device = std::make_shared<SerialDevice>(static_cast<int>(qHash(name)), name);
    if (device->open() == false) {
        qCInfo(logCategoryFlasherCli) << "Cannot open device.";
        emit finished(EXIT_FAILURE);
        return;
    }

    flasher_ = std::make_unique<Flasher>(device, "firmware.bin");

    connect(flasher_.get(), &Flasher::finished, this, &FlasherCli::handleFinish);

    flasher_->flash();

}

void FlasherCli::handleFinish(bool success) {
    emit finished((success) ? EXIT_SUCCESS : EXIT_FAILURE);
}

}  // namespace
