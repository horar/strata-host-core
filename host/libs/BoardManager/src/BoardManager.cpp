#include "BoardManager.h"
#include "SerialDevice.h"
#include "BoardManagerConstants.h"
#include "logging/LoggingQtCategories.h"

#include <vector>

#include <QString>
#include <QSerialPortInfo>


namespace spyglass {

BoardManager::BoardManager() {
    connect(&m_timer, &QTimer::timeout, this, &BoardManager::checkNewSerialDevices);
}

void BoardManager::init() {
    m_timer.start(DEVICE_CHECK_INTERVAL_MS);
}

void BoardManager::sendMessage(const int connectionId, const QString &message) {
    QHash<int, SerialDeviceShPtr>::const_iterator it = m_openedSerialPorts.find(connectionId);
    if (it != m_openedSerialPorts.end()) {
        it.value()->write(message.toUtf8());
    }
    else {
        qCWarning(logCategoryBoardManager).nospace() << "Cannot send message, invalid connection ID: 0x" << hex << static_cast<uint>(connectionId);
        emit invalidOperation(connectionId);
    }
}

void BoardManager::disconnect(const int connectionId) {
    QHash<int, SerialDeviceShPtr>::iterator it = m_openedSerialPorts.find(connectionId);
    if (it != m_openedSerialPorts.end()) {
        it.value()->close();
        it.value().reset();
        m_openedSerialPorts.erase(it);

        emit boardDisconnected(connectionId);
    }
    else {
        qCWarning(logCategoryBoardManager).nospace() << "Cannot send disconnect, invalid connection ID: 0x" << hex << static_cast<uint>(connectionId);
        emit invalidOperation(connectionId);
    }
}

void BoardManager::reconnect(const int connectionId) {
    bool ok = false;
    QHash<int, SerialDeviceShPtr>::iterator it = m_openedSerialPorts.find(connectionId);
    if (it != m_openedSerialPorts.end()) {
        it.value()->close();
        it.value().reset();
        m_openedSerialPorts.erase(it);
        ok = true;
    }
    else {
        // desired port is not opened, check if it is connected
        if (m_serialPortsList.find(connectionId) != m_serialPortsList.end()) {
            ok = true;
        }
    }
    if (ok) {
        addedSerialPort(connectionId);
    }
    else {
        qCWarning(logCategoryBoardManager).nospace() << "Cannot send reconnect, invalid connection ID: 0x" << hex << static_cast<uint>(connectionId);
        emit invalidOperation(connectionId);
    }
}

QVariantMap BoardManager::getConnectionInfo(const int connectionId) {
    QHash<int, SerialDeviceShPtr>::const_iterator it = m_openedSerialPorts.find(connectionId);
    if (it != m_openedSerialPorts.end()) {
        return it.value()->getDeviceInfo();
    }
    else {
        qCWarning(logCategoryBoardManager).nospace() << "Cannot get connection info, invalid connection ID: 0x" << hex << static_cast<uint>(connectionId);
        emit invalidOperation(connectionId);
        return QVariantMap();
    }
}

QVector<int> BoardManager::connectionIds() {
    // from Qt 5.14 is possible to do this:
    // return QVector<int>(m_serialPortsList.cbegin(), m_serialPortsList.cend());
    return QVector<int>::fromStdVector(std::vector<int>(m_serialPortsList.cbegin(), m_serialPortsList.cend()));
}

void BoardManager::checkNewSerialDevices() {
#ifdef __APPLE__
    const QString usb_keyword("usb");
    const QString cu_keyword("cu");
#elif __linux__
    // TODO: this code was not tested on Linux, test it
    const QString usb_keyword("USB");
    const QString cu_keyword("CU");
#elif _WIN32
    const QString usb_keyword("COM");
#endif
    const quint16 vendor_id = 0x0403;
    const quint16 product_id = 0x6015;

    const auto serialPortInfos = QSerialPortInfo::availablePorts();
    std::set<int> ports;
    QHash<int, QString> id_to_name;

    for (const QSerialPortInfo &serialPortInfo : serialPortInfos) {
        const QString& name = serialPortInfo.portName();
        do {
            if (serialPortInfo.isNull()) {
                break;
            }
            if (! name.contains(usb_keyword)) {
                break;
            }
#if defined(__APPLE__) || defined(__linux__)
            if (! name.startsWith(cu_keyword)) {
                break;
            }
#endif
            if (! (serialPortInfo.hasVendorIdentifier() && serialPortInfo.vendorIdentifier() == vendor_id)) {
                break;
            }
            if (! (serialPortInfo.hasProductIdentifier() && serialPortInfo.productIdentifier() == product_id)) {
                break;
            }

            // conection ID must be int because of integration with QML
            int connectionId = static_cast<int>(qHash(name));
            auto ret = ports.emplace(connectionId);
            if (!ret.second) {
                // Error: hash already exists!
                qCCritical(logCategoryBoardManager).nospace() << "Cannot add device (hash conflict: 0x" << hex << static_cast<uint>(connectionId) << "): " << name;
                break;
            }
            id_to_name.insert(connectionId, name);

            // qCDebug(logCategoryBoardManager).nospace() << "Found serial device, ID: 0x" << hex << static_cast<uint>(connectionId) << ", name: " << name;
        } while (false);
    }

    std::set<int> added, removed;
    std::vector<int> opened;
    opened.reserve(added.size());

    // in case of multithread usage lock this block of code
    {  // this block of code modifies m_serialPortsList, m_openedSerialPorts, m_serialIdToName

        m_serialIdToName = std::move(id_to_name);

        computeListDiff(ports, added, removed);  // uses m_serialPortsList (needs old value from previous run)

        for (auto connectionId : removed) {
            removedSerialPort(connectionId);  // modifies m_openedSerialPorts
            emit boardDisconnected(connectionId);  // if this block of code is locked emit this after end of the block
        }

        for (auto connectionId : added) {
            if (addedSerialPort(connectionId)) {  // modifies m_openedSerialPorts, uses m_serialIdToName
                opened.emplace_back(connectionId);
                emit boardConnected(connectionId);  // if this block of code is locked emit this after end of the block
            }
        }

        m_serialPortsList = std::move(ports);
    }

    if (!opened.empty() || !removed.empty()) {
        // in case of multithread usage emit signals here (iterate over 'removed' and 'opened' containers)

        emit connectionIdsChanged();
    }
}

// in case of multithread usage mutex must be locked before calling this function (due to accessing m_serialPortsList)
void BoardManager::computeListDiff(std::set<int>& list, std::set<int>& added_ports, std::set<int>& removed_ports) {
    //create differences of the lists.. what is added / removed
    std::set_difference(list.begin(), list.end(),
                        m_serialPortsList.begin(), m_serialPortsList.end(),
                        std::inserter(added_ports, added_ports.begin()));

    std::set_difference(m_serialPortsList.begin(), m_serialPortsList.end(),
                        list.begin(), list.end(),
                        std::inserter(removed_ports, removed_ports.begin()));
}

// in case of multithread usage mutex must be locked before calling this function (due to modification m_openedSerialPorts)
bool BoardManager::addedSerialPort(const int connectionId) {
    const QString name = m_serialIdToName.value(connectionId);

    SerialDeviceShPtr device = std::make_shared<SerialDevice>(connectionId, name);

    if (device->open()) {
        m_openedSerialPorts.insert(connectionId, device);

        qCInfo(logCategoryBoardManager).nospace() << "Added new serial device: ID: 0x" << hex << static_cast<uint>(connectionId) << ", name: " << name;

        connect(device.get(), &SerialDevice::deviceReady, this, &BoardManager::boardReady);
        connect(device.get(), &SerialDevice::serialDeviceError, this, &BoardManager::boardError);
        connect(device.get(), &SerialDevice::msgFromDevice, this, &BoardManager::newMessage);

        device->launchDevice();

        return true;
    }
    else {
        qCWarning(logCategoryBoardManager).nospace() << "Cannot open serial device: ID: 0x" << hex << static_cast<uint>(connectionId) << ", name: " << name;
        return false;
    }
}

// in case of multithread usage mutex must be locked before calling this function (due to modification m_openedSerialPorts)
void BoardManager::removedSerialPort(const int connectionId) {
    QHash<int, SerialDeviceShPtr>::iterator it_op = m_openedSerialPorts.find(connectionId);
    if (it_op != m_openedSerialPorts.end()) {
        it_op.value()->close();
        it_op.value().reset();
        m_openedSerialPorts.erase(it_op);

        qCInfo(logCategoryBoardManager).nospace() << "Removed serial device 0x" << hex << static_cast<uint>(connectionId);
    }
}

}  // namespace
