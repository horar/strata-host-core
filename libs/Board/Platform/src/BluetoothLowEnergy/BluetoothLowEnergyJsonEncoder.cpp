#include "BluetoothLowEnergy/BluetoothLowEnergyJsonEncoder.h"

#include "logging/LoggingQtCategories.h"

namespace strata::device
{

bool BluetoothLowEnergyJsonEncoder::parseRequest(const rapidjson::Document & requestDocument, BluetoothLowEnergyAttribute & attribute)
{
    if (requestDocument.HasMember("payload") == false) {
        qCWarning(logCategoryDeviceBLE) << "Request missing payload";
        return false;
    }

    auto *payloadObject = &requestDocument["payload"];
    if (payloadObject->IsObject() == false) {
        qCWarning(logCategoryDeviceBLE) << "Payload is not an object";
        return false;
    }

    const rapidjson::GenericObject payload = payloadObject->GetObject();

    std::string serviceUuid;
    if (payload.HasMember("service") && payload["service"].IsString()) {
        serviceUuid = payload["service"].GetString();
    } else {
        qCWarning(logCategoryDeviceBLE) << "Request missing service";
        return false;
    }

    std::string characteristicUuid;
    if (payload.HasMember("characteristic") && payload["characteristic"].IsString()) {
        characteristicUuid = payload["characteristic"].GetString();
    } else {
        qCWarning(logCategoryDeviceBLE) << "Request missing characteristic";
        return false;
    }

    std::string descriptorUuid;
    if (payload.HasMember("descriptor")) {
        if (payload["descriptor"].IsString()) {
            descriptorUuid = payload["descriptor"].GetString();
        } else {
            qCWarning(logCategoryDeviceBLE) << "Request missing descriptor";
            return false;
        }
    }

    attribute.service = normalizeBleUuid(serviceUuid);
    if (attribute.service.isNull())
    {
        qCWarning(logCategoryDeviceBLE) << "Invalid service uuid";
        return false;
    }
    attribute.characteristic = normalizeBleUuid(characteristicUuid);
    if (attribute.characteristic.isNull())
    {
        qCWarning(logCategoryDeviceBLE) << "Invalid characteristic uuid";
        return false;
    }
    if (descriptorUuid.empty() == false) {
        attribute.descriptor = normalizeBleUuid(descriptorUuid);
        if (attribute.descriptor.isNull())
        {
            qCWarning(logCategoryDeviceBLE) << "Invalid descriptor uuid";
            return false;
        }
    } else {
        attribute.descriptor = QBluetoothUuid();
    }
    std::string data;
    if (payload.HasMember("data") && payload["data"].IsString()) {
        data = payload["data"].GetString();
    }
    attribute.data = QByteArray::fromHex(data.c_str());

    return true;
}

QBluetoothUuid BluetoothLowEnergyJsonEncoder::normalizeBleUuid(std::string uuid)
{
    QString tmpUuid = QString::fromStdString(uuid);
    tmpUuid = tmpUuid.remove('-').toLower();
    for (const auto &ch : tmpUuid) {
        if ((ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= "f")) {
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
        } else
        {
            return QByteArray(uuid).remove(8, BASE_UUID_SUFFIX_BYTES.length());
        }
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
    return R"({"ack":"write","payload":{"return_value":true,"return_string":"command valid","service":")" + shortenBleUuid(serviceUuid) + R"(","descriptor":")" + shortenBleUuid(descriptorUuid) + R"(","data":")" + data + R"("}})";
}

QByteArray BluetoothLowEnergyJsonEncoder::encodeAckReadDescriptor(const QByteArray &serviceUuid, const QByteArray &descriptorUuid)
{
    return R"({"ack":"read","payload":{"return_value":true,"return_string":"command valid","service":")" + shortenBleUuid(serviceUuid) + R"(","descriptor":")" + shortenBleUuid(descriptorUuid) + R"("}})";
}

QByteArray BluetoothLowEnergyJsonEncoder::encodeNotificationReadDescriptor(const QByteArray &serviceUuid, const QByteArray &descriptorUuid, const QByteArray &data)
{
    return R"({"notification":{"value":"read","payload":{"service":")" + shortenBleUuid(serviceUuid) + R"(","descriptor":")" + shortenBleUuid(descriptorUuid) + R"(","data":")" + data + R"("}}})";
}

QByteArray BluetoothLowEnergyJsonEncoder::encodeNAck(const QByteArray &command, const QByteArray &details, const QByteArray &serviceUuid)
{
    return R"({"ack":")" + command + R"(","payload":{"return_value":false,"return_string":")" + details + R"(","service":")" + shortenBleUuid(serviceUuid) + R"("}})";
}

QByteArray BluetoothLowEnergyJsonEncoder::encodeNotificationError(const QByteArray &status, const QByteArray &details)
{
    return R"({"notification":{"value":"error","payload":{"status":")" + status + R"(","details":")" + details + R"("}}})";
}


}  // namespace strata::device
