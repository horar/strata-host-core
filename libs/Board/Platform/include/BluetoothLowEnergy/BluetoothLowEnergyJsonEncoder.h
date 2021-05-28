#pragma once

#include <rapidjson/document.h>
#include <QBluetoothUuid>

namespace strata::device
{
const QString BASE_UUID_SUFFIX = "-0000-1000-8000-00805f9b34fb";
const QByteArray BASE_UUID_SUFFIX_BYTES = BASE_UUID_SUFFIX.toUtf8();


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

    /**
     * If the UUID can be shortened to 32bit or 16bit, it will be shortened.
     * @param uuid the original UUID
     * @return resulting UUID, shortened if possible
     */
    static QByteArray shortenBleUuid(const QByteArray &uuid);

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
