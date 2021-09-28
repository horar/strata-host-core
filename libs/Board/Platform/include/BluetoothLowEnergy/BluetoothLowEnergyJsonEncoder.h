/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
    struct BluetoothLowEnergyAttribute {
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
     * @param[out] addresses After successful call, will contained parsed data
     * about the attribute to be read/written.
     * @return error message. Or null string if document was parsed successfully.
     */
    [[nodiscard]] static QString parseRequest(const rapidjson::Document &requestDocument,
                                           BluetoothLowEnergyAttribute &attribute);

    /**
     * Creates QBluetoothUuid from string. Accepts 2B, 4B and 32B UUIDs.
     * If uuid is invalid, returns null uuid (00000000-0000-0000-0000-000000000000)
     * @param uuid UUID string to be processed.
     * @return QBluetoothUuid based on the UUID string.
     */
    static QBluetoothUuid normalizeBleUuid(const std::string &uuid);

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

    static QByteArray encodeNAck(const QByteArray &command, const QByteArray &details, const QByteArray &serviceUuid);
    static QByteArray encodeNotificationError(const QByteArray &status, const QByteArray &details);

    static QByteArray encodeAckGetFirmwareInfo();
    static QByteArray encodeNotificationGetFirmwareInfo();
    static QByteArray encodeAckRequestPlatformId();
    static QByteArray encodeNAckRequestPlatformId();
    static QByteArray encodeNotificationPlatformId(const QString &name, const QMap<QBluetoothUuid, QString> &platformIdentification);

    /**
     * Parses characteristic value from Strata ID service, converts it to string (will be used in JSON response)
     * and stores it into the platformIdentification parameter.
     * @param characteristicUuid UUID of the characteristic
     * @param value value to be parsed
     * @param[out] platformIdentification converted value will be stored here
     */
    static void parseCharacteristicValue(const QBluetoothUuid &characteristicUuid, const QByteArray &value, QMap<QBluetoothUuid, QString> &platformIdentification);

};

}  // namespace strata::device
