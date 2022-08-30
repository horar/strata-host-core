/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "BluetoothLowEnergy/BluetoothLowEnergyJsonEncoder.h"
#include "BluetoothLowEnergy/BluetoothLowEnergyDevice.h"

#include "logging/LoggingQtCategories.h"

namespace strata::device
{

QString BluetoothLowEnergyJsonEncoder::parseRequest(const rapidjson::Document & requestDocument, BluetoothLowEnergyAttribute & attribute)
{
    if (requestDocument.HasMember("payload") == false) {
        qCWarning(lcDeviceBLE) << "Request missing payload";
        return "Request missing payload";
    }

    auto *payloadObject = &requestDocument["payload"];
    if (payloadObject->IsObject() == false) {
        qCWarning(lcDeviceBLE) << "Payload is not an object";
        return "Payload is not an object";
    }

    const rapidjson::GenericObject payload = payloadObject->GetObject();

    std::string serviceUuid;
    if (payload.HasMember("service") && payload["service"].IsString()) {
        serviceUuid = payload["service"].GetString();
    } else {
        qCWarning(lcDeviceBLE) << "Request missing service";
        return "Request missing service";
    }

    std::string characteristicUuid;
    if (payload.HasMember("characteristic") && payload["characteristic"].IsString()) {
        characteristicUuid = payload["characteristic"].GetString();
    } else {
        qCWarning(lcDeviceBLE) << "Request missing characteristic";
        return "Request missing characteristic";
    }

    std::string descriptorUuid;
    if (payload.HasMember("descriptor")) {
        if (payload["descriptor"].IsString()) {
            descriptorUuid = payload["descriptor"].GetString();
        } else {
            qCWarning(lcDeviceBLE) << "Malformed descriptor";
            return "Malformed descriptor";
        }
    }

    attribute.service = normalizeBleUuid(serviceUuid);
    if (attribute.service.isNull())
    {
        qCWarning(lcDeviceBLE) << "Invalid service uuid";
        return "Invalid service uuid";
    }
    attribute.characteristic = normalizeBleUuid(characteristicUuid);
    if (attribute.characteristic.isNull())
    {
        qCWarning(lcDeviceBLE) << "Invalid characteristic uuid";
        return "Invalid characteristic uuid";
    }
    if (descriptorUuid.empty() == false) {
        attribute.descriptor = normalizeBleUuid(descriptorUuid);
        if (attribute.descriptor.isNull())
        {
            qCWarning(lcDeviceBLE) << "Invalid descriptor uuid";
            return "Invalid descriptor uuid";
        }
    } else {
        attribute.descriptor = QBluetoothUuid();
    }
    std::string data;
    if (payload.HasMember("data") && payload["data"].IsString()) {
        data = payload["data"].GetString();
        attribute.data = QByteArray::fromHex(data.c_str());
    }

    return QString();
}

QBluetoothUuid BluetoothLowEnergyJsonEncoder::normalizeBleUuid(const std::string &uuid)
{
    QString tmpUuid = QString::fromStdString(uuid);
    tmpUuid = tmpUuid.remove('-').toLower();
    for (const auto &ch : qAsConst(tmpUuid)) {
        if ((ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f')) {
            continue;
        }
        return QBluetoothUuid(); // error
    }

    if (tmpUuid.length() == 32) {
        tmpUuid.insert(8, '-').insert(13, '-').insert(18, '-').insert(23, '-');
    } else if (tmpUuid.length() == 8) {
        tmpUuid = tmpUuid + BASE_UUID_SUFFIX;
    } else if (tmpUuid.length() == 4) {
        tmpUuid = "0000" + tmpUuid + BASE_UUID_SUFFIX;
    } else {
        return QBluetoothUuid(); // error
    }
    tmpUuid = '{' + tmpUuid + '}';
    return QBluetoothUuid(tmpUuid);
}

QByteArray BluetoothLowEnergyJsonEncoder::shortenBleUuid(const QByteArray &uuid)
{
    if (uuid.endsWith(BASE_UUID_SUFFIX_BYTES)) {
        if (uuid.startsWith("0000")) {
            return QByteArray(uuid).remove(8, BASE_UUID_SUFFIX_BYTES.length()).remove(0, 4);
        }
        return QByteArray(uuid).remove(8, BASE_UUID_SUFFIX_BYTES.length());
    }
    return uuid;
}

QByteArray BluetoothLowEnergyJsonEncoder::encodeAckWriteCharacteristic(const QByteArray &serviceUuid, const QByteArray &characteristicUuid, const QByteArray &data)
{
    return R"({"ack":"write","payload":{"return_value":true,"return_string":"command valid","service":")" + shortenBleUuid(serviceUuid) + R"(","characteristic":")" + shortenBleUuid(characteristicUuid) + R"(","data":")" + data + R"("}})";
}

QByteArray BluetoothLowEnergyJsonEncoder::encodeAckReadCharacteristic(const QByteArray &serviceUuid, const QByteArray &characteristicUuid)
{
    return R"({"ack":"read","payload":{"return_value":true,"return_string":"command valid","service":")" + shortenBleUuid(serviceUuid) + R"(","characteristic":")" + shortenBleUuid(characteristicUuid) + R"("}})";
}

QByteArray BluetoothLowEnergyJsonEncoder::encodeNotificationCharacteristic(const QByteArray &serviceUuid, const QByteArray &characteristicUuid, const QByteArray &data)
{
    return R"({"notification":{"value":"notify","payload":{"service":")" + shortenBleUuid(serviceUuid) + R"(","characteristic":")" + shortenBleUuid(characteristicUuid) + R"(","data":")" + data + R"("}}})";
}

QByteArray BluetoothLowEnergyJsonEncoder::encodeNotificationReadCharacteristic(const QByteArray &serviceUuid, const QByteArray &characteristicUuid, const QByteArray &data)
{
    return R"({"notification":{"value":"read","payload":{"service":")" + shortenBleUuid(serviceUuid) + R"(","characteristic":")" + shortenBleUuid(characteristicUuid) + R"(","data":")" + data + R"("}}})";
}

QByteArray BluetoothLowEnergyJsonEncoder::encodeAckWriteDescriptor(const QByteArray &serviceUuid, const QByteArray &descriptorUuid, const QByteArray &data)
{
    return R"({"ack":"write_descriptor","payload":{"return_value":true,"return_string":"command valid","service":")" + shortenBleUuid(serviceUuid) + R"(","descriptor":")" + shortenBleUuid(descriptorUuid) + R"(","data":")" + data + R"("}})";
}

QByteArray BluetoothLowEnergyJsonEncoder::encodeNAck(const QByteArray &command, const QByteArray &details, const QByteArray &serviceUuid)
{
    return R"({"ack":")" + command + R"(","payload":{"return_value":false,"return_string":")" + details + R"(","service":")" + shortenBleUuid(serviceUuid) + R"("}})";
}

QByteArray BluetoothLowEnergyJsonEncoder::encodeNotificationError(const QByteArray &status, const QByteArray &details)
{
    return R"({"notification":{"value":"error","payload":{"status":")" + status + R"(","details":")" + details + R"("}}})";
}

QByteArray BluetoothLowEnergyJsonEncoder::encodeAckGetFirmwareInfo()
{
    return R"({"ack":"get_firmware_info","payload":{"return_value":true,"return_string":"command valid"}})";
}

QByteArray BluetoothLowEnergyJsonEncoder::encodeNotificationGetFirmwareInfo()
{
    // hard-coded reply, because FOTA is not implemented (yet?)
    return  R"({"notification":{"value":"get_firmware_info","payload": {)"
            R"("api_version":"2.0","active":"application","bootloader": {},"application": {"version":"0.0.0","date":""}}}})";
}

QByteArray BluetoothLowEnergyJsonEncoder::encodeAckRequestPlatformId()
{
    return R"({"ack":"request_platform_id","payload":{"return_value":true,"return_string":"command valid"}})";
}

QByteArray BluetoothLowEnergyJsonEncoder::encodeNAckRequestPlatformId()
{
    return R"({"ack":"request_platform_id","payload":{"return_value":false,"return_string":"command not supported"}})";
}

QByteArray BluetoothLowEnergyJsonEncoder::encodeNotificationPlatformId(const QString &name, const QMap<QBluetoothUuid, QString> &platformIdentification)
{
    QString retVal;
    retVal = R"({"notification":{"value":"platform_id","payload":{"name":")" + name + R"(")";

    QString controllerType = platformIdentification.value(ble::STRATA_ID_SERVICE_CONTROLLER_TYPE, QString());
    if (controllerType.isNull() == false) {
        retVal += R"(,"controller_type":)" + controllerType;
    }
    QString boardConnected = platformIdentification.value(ble::STRATA_ID_SERVICE_BOARD_CONNECTED, QString());
    if (controllerType.isNull() || controllerType != "2" || boardConnected != "0") {
        //embedded board or assisted with connected board
        QString platformId = platformIdentification.value(ble::STRATA_ID_SERVICE_PLATFORM_ID, QString());
        if (platformId.isNull() == false) {
            retVal += R"(,"platform_id":)" + platformId;
        }
        QString classId = platformIdentification.value(ble::STRATA_ID_SERVICE_CLASS_ID, QString());
        if (classId.isNull() == false) {
            retVal += R"(,"class_id":)" + classId;
        }
        QString boardCount = platformIdentification.value(ble::STRATA_ID_SERVICE_BOARD_COUNT, QString());
        if (boardCount.isNull() == false) {
            retVal += R"(,"board_count":)" + boardCount;
        }
    }

    if (controllerType == "2") {
        //assisted
        QString controllerPlatformId = platformIdentification.value(ble::STRATA_ID_SERVICE_CONTROLLER_PLATFORM_ID, QString());
        if (controllerPlatformId.isNull() == false) {
            retVal += R"(,"controller_platform_id":)" + controllerPlatformId;
        }
        QString controllerClassId = platformIdentification.value(ble::STRATA_ID_SERVICE_CONTROLLER_CLASS_ID, QString());
        if (controllerClassId.isNull() == false) {
            retVal += R"(,"controller_class_id":)" + controllerClassId;
        }
        QString controllerBoardCount = platformIdentification.value(ble::STRATA_ID_SERVICE_CONTROLLER_BOARD_COUNT, QString());
        if (controllerBoardCount.isNull() == false) {
            retVal += R"(,"controller_board_count":)" + controllerBoardCount;
        }
        QString fwClassId = platformIdentification.value(ble::STRATA_ID_SERVICE_FW_CLASS_ID, QString());
        if (fwClassId.isNull() == false) {
            retVal += R"(,"fw_class_id":)" + fwClassId;
        }
    }

    retVal += R"(}}})";
    return retVal.toUtf8();
}


void BluetoothLowEnergyJsonEncoder::parseCharacteristicValue(const QBluetoothUuid &characteristicUuid, const QByteArray &value, QMap<QBluetoothUuid, QString> &platformIdentification)
{
    if (characteristicUuid == ble::STRATA_ID_SERVICE_PLATFORM_ID ||
        characteristicUuid == ble::STRATA_ID_SERVICE_CLASS_ID ||
        characteristicUuid == ble::STRATA_ID_SERVICE_CONTROLLER_PLATFORM_ID ||
        characteristicUuid == ble::STRATA_ID_SERVICE_CONTROLLER_CLASS_ID ||
        characteristicUuid == ble::STRATA_ID_SERVICE_FW_CLASS_ID) {

        if (value.size() != 16) {
            qCWarning(lcDeviceBLE) << "Invalid size of" << characteristicUuid << "actual" << value.size() << "expected 16";
            return;
        }
        QByteArray reverseValue = value;
        std::reverse(reverseValue.begin(), reverseValue.end()); // little endian -> big endian
        platformIdentification.insert(characteristicUuid,"\"" + QBluetoothUuid(*((quint128 *)reverseValue.data())).toByteArray(QBluetoothUuid::WithoutBraces) + "\"");
    }
    if (characteristicUuid == ble::STRATA_ID_SERVICE_BOARD_CONNECTED) {
        if (value.size() != 1) {
            qCWarning(lcDeviceBLE) << "Invalid size of" << characteristicUuid << "actual" << value.size() << "expected 1";
            return;
        }
        platformIdentification.insert(characteristicUuid,QString::number((quint8)value[0]));
    }
    if (characteristicUuid == ble::STRATA_ID_SERVICE_CONTROLLER_TYPE) {
        if (value.size() != 2) {
            qCWarning(lcDeviceBLE) << "Invalid size of" << characteristicUuid << "actual" << value.size() << "expected 2";
            return;
        }
        platformIdentification.insert(characteristicUuid,QString::number(((quint16)value[0]) + (((quint16)value[1]) << 8)));
    }
    if (characteristicUuid == ble::STRATA_ID_SERVICE_BOARD_COUNT ||
        characteristicUuid == ble::STRATA_ID_SERVICE_CONTROLLER_BOARD_COUNT) {
        if (value.size() != 4) {
            qCWarning(lcDeviceBLE) << "Invalid size of" << characteristicUuid << "actual" << value.size() << "expected 4";
            return;
        }
        platformIdentification.insert(characteristicUuid,QString::number(((quint32)value[0]) + (((quint32)value[1]) << 8) + (((quint32)value[2]) << 16) + (((quint32)value[3]) << 24)));
    }
}

}  // namespace strata::device
