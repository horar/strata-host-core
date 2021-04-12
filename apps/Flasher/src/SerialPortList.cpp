#include "SerialPortList.h"

#include <QSerialPortInfo>

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

QString SerialPortList::name(int index) const {
    return portNames_.value(index);
}

QList<QString> SerialPortList::list() const {
    return portNames_;
}

int SerialPortList::count() const {
    return portNames_.count();
}

}  // namespace
