#pragma once

#include <rapidjson/document.h>
#include <QBluetoothUuid>

namespace strata::device
{
class BluetoothLowEnergyJsonEncoder
{
public:
    struct BluetoothLowEnergyAttributes {
        QBluetoothUuid service;
        QBluetoothUuid characteristic;
        QBluetoothUuid descriptor;
        QByteArray data;
    };

    /**
     * Only static methods in the class, no need to construct it.
     */
    BluetoothLowEnergyJsonEncoder() = delete;
    /**
     * Parses GATT related data out of JSON request.
     * @param requestDocument Document to be parsed.
     * @param[out] addresses After successful call, will contained parsed data.
     * @return true iff document was parsed successfully.
     */
    [[nodiscard]] static bool parseRequest(const rapidjson::Document &requestDocument,
                                           BluetoothLowEnergyAttributes &addresses);

    /**
     * Creates QBluetoothUuid from string. Accepts 2B, 4B and 32B UUIDs.
     * If uuid is invalid, returns null uuid (00000000-0000-0000-0000-000000000000)
     * @param uuid UUID string to be processed.
     * @return QBluetoothUuid based on the UUID string.
     */
    static QBluetoothUuid normalizeBleUuid(std::string uuid);

    static QByteArray encodeAckWriteCharacteristic(const QByteArray &serviceUuid, const QByteArray &characteristicUuid, const QByteArray &data);
    static QByteArray encodeAckReadCharacteristic(const QByteArray &serviceUuid, const QByteArray &characteristicUuid);
    static QByteArray encodeNotificationCharacteristic(const QByteArray &serviceUuid, const QByteArray &characteristicUuid, const QByteArray &data);
    static QByteArray encodeNotificationReadCharacteristic(const QByteArray &serviceUuid, const QByteArray &characteristicUuid, const QByteArray &data);

    static QByteArray encodeAckWriteDescriptor(const QByteArray &serviceUuid, const QByteArray &descriptorUuid, const QByteArray &data);
    static QByteArray encodeAckReadDescriptor(const QByteArray &serviceUuid, const QByteArray &descriptorUuid);
    static QByteArray encodeNotificationReadDescriptor(const QByteArray &serviceUuid, const QByteArray &descriptorUuid, const QByteArray &data);

    static QByteArray encodeNAck(const QByteArray &command, const QByteArray &details, const QByteArray &serviceUuid);
    static QByteArray encodeNotificationError(const QByteArray &status, const QByteArray &details);
};

}  // namespace strata::device
