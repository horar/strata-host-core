#include <Mock/MockDeviceControl.h>
#include <QFile>
#include <Buypass.h>
#include <CodecBase64.h>
#include <QDir>

#include "logging/LoggingQtCategories.h"

namespace strata::device {

MockDeviceControl::MockDeviceControl(QObject *parent)
    : QObject(parent)
{
}

MockDeviceControl::~MockDeviceControl()
{
}

bool MockDeviceControl::mockIsOpenEnabled() const
{
    return isOpenEnabled_;
}

bool MockDeviceControl::mockIsLegacy() const
{
    return isLegacy_;
}

bool MockDeviceControl::mockIsBootloader() const
{
    return isBootloader_;
}

MockCommand MockDeviceControl::mockGetCommand() const
{
    return command_;
}

MockResponse MockDeviceControl::mockGetResponse() const
{
    return response_;
}

MockVersion MockDeviceControl::mockGetVersion() const
{
    return version_;
}

bool MockDeviceControl::mockSetOpenEnabled(bool enabled)
{
    if (isOpenEnabled_ != enabled) {
        isOpenEnabled_ = enabled;
        qCDebug(logCategoryDeviceMock) << "Configured open enabled to" << isOpenEnabled_;
        return true;
    }
    qCDebug(logCategoryDeviceMock) << "Open enabled already configured to" << isOpenEnabled_;
    return false;
}

bool MockDeviceControl::mockSetLegacy(bool legacy)
{
    if (isLegacy_ != legacy) {
        isLegacy_ = legacy;
        qCDebug(logCategoryDeviceMock) << "Configured legacy mode to" << isLegacy_;
        return true;
    }
    qCDebug(logCategoryDeviceMock) << "Legacy mode already configured to" << isLegacy_;
    return false;
}

bool MockDeviceControl::mockSetCommand(MockCommand command)
{
    if (command_ != command) {
        command_ = command;
        qCDebug(logCategoryDeviceMock) << "Configured command from command-response pair to"
                                       << command_<< ":" << response_;
        return true;
    }
    qCDebug(logCategoryDeviceMock) << "Command from command-response pair already configured to"
                                   << command_<< ":" << response_;
    return false;
}

bool MockDeviceControl::mockSetResponse(MockResponse response)
{
    if (response_ != response) {
        response_ = response;
        qCDebug(logCategoryDeviceMock) << "Configured response command-response pair to"
                                       << command_<< ":" << response_;
        return true;
    }
    qCDebug(logCategoryDeviceMock) << "Response from command-response pair already configured to"
                                   << command_<< ":" << response_;
    return false;
}

bool MockDeviceControl::mockSetResponseForCommand(MockResponse response, MockCommand command)
{
    if ((command_ != command) || (response_ != response)) {
        command_ = command;
        response_ = response;
        qCDebug(logCategoryDeviceMock) << "Configured command-response pair to"
                                       << command_<< ":" << response_;
        return true;
    }
    qCDebug(logCategoryDeviceMock) << "Command-response pair already configured to"
                                   << command_<< ":" << response_;
    return false;
}

bool MockDeviceControl::mockSetVersion(MockVersion version)
{
    if (version_ != version) {
        version_ = version;
        qCDebug(logCategoryDeviceMock) << "Configured version to" << version_;
        return true;
    }
    qCDebug(logCategoryDeviceMock) << "Version already configured to" << version_;
    return false;
}

bool MockDeviceControl::mockSetAsBootloader(bool isBootloader)
{
    if (isBootloader_ != isBootloader) {
        isBootloader_ = isBootloader;
        qCDebug(logCategoryDeviceMock) << "Configured is bootloader to" << isBootloader_;
        return true;
    }
    qCDebug(logCategoryDeviceMock) << "Is bootloader already configured to" << isBootloader_;
    return false;
}

bool MockDeviceControl::mockCreateMockFirmware(bool createFirmware)
{
    if (createFirmware_ != createFirmware) {
        createFirmware_ = createFirmware;
        qCDebug(logCategoryDeviceMock) << "Configured create firmware to" << createFirmware_;

        if (createFirmware_ && mockFirmware_.exists() == false) {
            createMockFirmware();
            getExpectedValues(mockFirmware_.fileName());
        }
        return true;
    }
    qCDebug(logCategoryDeviceMock) << "Create firmware already configured to" << createFirmware_;
    return false;
}

std::vector<QByteArray> MockDeviceControl::getResponses(const QByteArray& request)
{
    rapidjson::Document requestDoc;
    rapidjson::ParseResult parseResult = requestDoc.Parse(request.data(), request.size());
    std::vector<QByteArray> retVal;

    if (parseResult.IsError()) {
        return std::vector<QByteArray>({test_commands::nack_badly_formatted_json});
    }

    if (requestDoc.HasMember("cmd") == false) {
        return std::vector<QByteArray>({test_commands::nack_badly_formatted_json});
    }

    auto *qCmd = &requestDoc["cmd"];
    if (qCmd->IsString()) {
        std::string cmd = qCmd->GetString();
        MockCommand recievedCommand = convertCommandToEnum(cmd);

        retVal.push_back(test_commands::ack);

        bool customResponse = (command_ == recievedCommand) || (command_ == MockCommand::Any_command);
        if (customResponse) {
            if (response_ == MockResponse::Nack) {
                retVal.pop_back();  // remove ack
                retVal.push_back(test_commands::nack_command_not_found);
                return replacePlaceholders(retVal, requestDoc);
            } else if (response_ == MockResponse::No_JSON) {
                retVal.push_back(test_commands::no_JSON_response);
                return replacePlaceholders(retVal, requestDoc);
            }
        }

        switch (recievedCommand) {
        case MockCommand::Get_firmware_info:
            if (version_ == MockVersion::Version_1) {
                if (isLegacy_) {
                    retVal.pop_back();  // remove ack
                    retVal.push_back(test_commands::nack_command_not_found);
                } else if (customResponse) {
                    switch(response_) {
                    case MockResponse::No_payload: {
                        retVal.push_back(test_commands::get_firmware_info_response_no_payload);
                    } break;
                    case MockResponse::Invalid: {
                        retVal.push_back(test_commands::get_firmware_info_response_invalid);
                    } break;
                    default: {
                        retVal.push_back(test_commands::get_firmware_info_response);
                    } break;
                    }
                } else {
                    retVal.push_back(test_commands::get_firmware_info_response);
                }
            } else if (version_ == MockVersion::Version_2) {
                if (customResponse) {
                    switch(response_) {
                    case MockResponse::Platform_config_embedded_app:
                    case MockResponse::Platform_config_assisted_app:
                    case MockResponse::Platform_config_assisted_no_board: {
                        retVal.push_back(test_commands::get_firmware_info_response_ver2_application);
                    } break;
                    case MockResponse::Platform_config_embedded_bootloader:
                    case MockResponse::Platform_config_assisted_bootloader:{
                        retVal.push_back(test_commands::get_firmware_info_response_ver2_bootloader);
                    } break;
                    case MockResponse::No_payload: {
                        retVal.push_back(test_commands::get_firmware_info_response_no_payload);
                    } break;
                    case MockResponse::Invalid:{
                        retVal.push_back(test_commands::get_firmware_info_response_ver2_invalid);
                    } break;
                    default: {
                        retVal.push_back(test_commands::get_firmware_info_response);
                    } break;
                    }
                } else {
                    retVal.push_back(test_commands::get_firmware_info_response);
                }
            } else {
                retVal.push_back(test_commands::get_firmware_info_response);
            }
            break;
        case MockCommand::Request_platform_id:
            if (version_ == MockVersion::Version_1) {
                if (isBootloader_) {
                    if (customResponse) {
                        switch(response_) {
                        case MockResponse::No_payload: {
                            retVal.push_back(test_commands::request_platform_id_response_bootloader_no_payload);
                        } break;
                        case MockResponse::Invalid: {
                            retVal.push_back(test_commands::request_platform_id_response_bootloader_invalid);
                        } break;
                        default: {
                            retVal.push_back(test_commands::request_platform_id_response_bootloader);
                        } break;
                        }
                    } else {
                        retVal.push_back(test_commands::request_platform_id_response_bootloader);
                    }
                } else {
                    if (customResponse) {
                        switch(response_) {
                        case MockResponse::No_payload: {
                            retVal.push_back(test_commands::request_platform_id_response_no_payload);
                        } break;
                        case MockResponse::Invalid: {
                            retVal.push_back(test_commands::request_platform_id_response_invalid);
                        } break;
                        default: {
                            retVal.push_back(test_commands::request_platform_id_response);
                        } break;
                        }
                    } else {
                        retVal.push_back(test_commands::request_platform_id_response);
                    }
                }
            } else if (version_ == MockVersion::Version_2) {
                if (customResponse) {
                    switch(response_) {
                    case MockResponse::Platform_config_embedded_app: {
                        retVal.push_back(test_commands::request_platform_id_response_ver2_embedded);
                    } break;
                    case MockResponse::Platform_config_assisted_app: {
                        retVal.push_back(test_commands::request_platform_id_response_ver2_assisted);
                    } break;
                    case MockResponse::Platform_config_assisted_no_board: {
                        retVal.push_back(test_commands::request_platform_id_response_ver2_assisted_without_board);
                    } break;
                    case MockResponse::Platform_config_embedded_bootloader: {
                        retVal.push_back(test_commands::request_platform_id_response_ver2_embedded_bootloader);
                    } break;
                    case MockResponse::Platform_config_assisted_bootloader:{
                        retVal.push_back(test_commands::request_platform_id_response_ver2_assisted_bootloader);
                    } break;
                    case MockResponse::No_payload: {
                        retVal.push_back(test_commands::request_platform_id_response_no_payload);
                    } break;
                    case MockResponse::Invalid: {
                        retVal.push_back(test_commands::request_platform_id_response_invalid);
                    } break;
                    default: {
                        retVal.push_back(test_commands::request_platform_id_response);
                    } break;
                    }
                } else {
                    retVal.push_back(test_commands::request_platform_id_response);
                }
            } else {
                retVal.push_back(test_commands::request_platform_id_response);
            }
            break;
        case MockCommand::Start_bootloader:
            isBootloader_ = true;
            if (customResponse) {
                switch(response_) {
                case MockResponse::No_payload: {
                    retVal.push_back(test_commands::start_bootloader_response_no_payload);
                } break;
                case MockResponse::Invalid: {
                    retVal.push_back(test_commands::start_bootloader_response_invalid);
                } break;
                default: {
                    retVal.push_back(test_commands::start_bootloader_response);
                } break;
                }
            } else {
                retVal.push_back(test_commands::start_bootloader_response);
            }
            break;
        case MockCommand::Start_application:
            isBootloader_ = false;
            if (customResponse) {
                switch(response_) {
                case MockResponse::No_payload: {
                    retVal.push_back(test_commands::start_application_response_no_payload);
                } break;
                case MockResponse::Invalid: {
                    retVal.push_back(test_commands::start_application_response_invalid);
                } break;
                default: {
                    retVal.push_back(test_commands::start_application_response);
                } break;
                }
            } else {
                retVal.push_back(test_commands::start_application_response);
            }
            break;

        case MockCommand::Flash_firmware:
            if (customResponse) {
                switch (response_) {
                case MockResponse::Flash_firmware_resend_chunk: {
                    retVal.push_back(test_commands::flash_firmware_response_resend_chunk);
                } break;
                case MockResponse::Flash_firmware_memory_error: {
                    retVal.push_back(test_commands::flash_firmware_response_memory_error);
                } break;
                case MockResponse::Flash_firmware_invalid_cmd_sequence: {
                    retVal.push_back(test_commands::flash_firmware_response_invalid_cmd_sequence);
                } break;
                case MockResponse::Flash_firmware_invalid_value: {
                    retVal.push_back(test_commands::flash_firmware_invalid_value);
                } break;
                default: {
                    retVal.push_back(test_commands::flash_firmware_response);
                } break;
                }
            } else {
                retVal.push_back(test_commands::flash_firmware_response);
            }
            break;

        case MockCommand::Flash_bootloader:
            retVal.push_back(test_commands::flash_bootloader_response);
            break;

        case MockCommand::Start_flash_firmware:
            if (customResponse) {
                switch (response_) {
                case MockResponse::Start_flash_firmware_invalid: {
                    retVal.push_back(test_commands::start_flash_firmware_response_invalid);
                } break;
                case MockResponse::Start_flash_firmware_invalid_command: {
                    retVal.push_back(test_commands::start_flash_firmware_response_invalid_command);
                } break;
                case MockResponse::Start_flash_firmware_too_large: {
                    retVal.push_back(test_commands::start_flash_firmware_response_firmware_too_large);
                } break;
                default: {
                    retVal.push_back(test_commands::start_flash_firmware_response);
                } break;
                }
            } else {
            retVal.push_back(test_commands::start_flash_firmware_response);
            }
            break;

        case MockCommand::Start_flash_bootloader:
            retVal.push_back(test_commands::start_flash_bootloader_response);
            break;

        case MockCommand::Set_assisted_platform_id:
            retVal.push_back(test_commands::set_assisted_platform_id_response);
            break;

        case MockCommand::Start_backup_firmware:
            retVal.push_back(test_commands::start_backup_firmware_response);
            break;

        case MockCommand::Backup_firmware:
            retVal.push_back(test_commands::backup_firmware_response);
            break;

        default: {
            retVal.pop_back();  // remove ack
            retVal.push_back(test_commands::nack_command_not_found);
        } break;
        }
    } else {
        return std::vector<QByteArray>({test_commands::nack_badly_formatted_json});
    }

    return replacePlaceholders(retVal, requestDoc);
}

QString MockDeviceControl::getPlaceholderValue(const QString placeholder, const rapidjson::Document &requestDoc)
{
    QStringList placeholderSplit = placeholder.split(".");
    QString placeholderNamespace = placeholderSplit[0];
    placeholderSplit.removeAt(0);

    if (0 == placeholderNamespace.compare("request") && placeholderSplit.length() >= 1) {
        const rapidjson::Value *targetDocumentNode = &requestDoc;
        for (auto placeholderPart : placeholderSplit) {
            if (!targetDocumentNode->IsObject() ||
                !targetDocumentNode->HasMember(placeholderPart.toStdString().c_str())) {
                //QFAIL_(
                //    ("Problem replacing placeholder <" + placeholder + ">").toStdString().c_str());
                return placeholder;
            }
            targetDocumentNode = &(*targetDocumentNode)[placeholderPart.toStdString().c_str()];
        }

        if (targetDocumentNode->IsString()) {
            return targetDocumentNode->GetString();
        }
    }

    if (0 == placeholderNamespace.compare("firmware") && placeholderSplit.length() >= 1) {

        if (createFirmware_ == false) {
            mockCreateMockFirmware(true); //once start_backup_firmware is recieved the mockFirmware is created
        }
        actualChunk_ = 0; //begin of backup_firmware

        if (placeholder == "firmware.size") {
            return QString::number(mockFirmware_.size());
        }
        if (placeholder == "firmware.chunks") {
            return QString::number(expectedChunksCount_);
        }
    }

    if (0 == placeholderNamespace.compare("chunk") && placeholderSplit.length() >= 1) {

        if (actualChunk_ < expectedChunksCount_ && createFirmware_) {
            if (payloadCount_ == 4) { //once 4 payloads are recieved(number,size,crc,data) the actual chunks' number iterates
                actualChunk_++;
                payloadCount_ = 0;
            }
            payloadCount_++;
            if (placeholder == "chunk.number") {
                return QString::number(actualChunk_);
            }
            if (placeholder == "chunk.size") {
                return QString::number(expectedChunkSize_[actualChunk_]);
            }
            if (placeholder == "chunk.crc") {
                return QString::number(expectedChunkCrc_[actualChunk_]);
            }
            if (placeholder == "chunk.data") {
                return expectedChunkData_[actualChunk_];
            }
        } else {
            createFirmware_ = false;
            if (placeholder == "chunk.number") {
                return QString::number(0);
            }
            if (placeholder == "chunk.size") {
                return QString::number(0);
            }
            if (placeholder == "chunk.crc") {
                return QString::number(0);
            }
            if (placeholder == "chunk.data") {
                return "";
            }
        }
    }// fallthrough
    // add other namespaces as required in the future (e.g. refer to mock variables)
    //qWarning() << (("Problem replacing placeholder <" + placeholder + ">").toStdString().c_str());
    return placeholder;  // fallback, return the value as is
}

const std::vector<QByteArray> MockDeviceControl::replacePlaceholders(const std::vector<QByteArray> &responses,
                                                               const rapidjson::Document &requestDoc)
{
    std::vector<QByteArray> retVal;
    std::map<QString, QString> replacements;

    // find and resolve placeholders
    for (const auto& response : responses) {
        QString responseString(response);

        QRegularExpressionMatchIterator rxIterator =
            test_commands::parameterRegex.globalMatch(responseString);
        while (rxIterator.hasNext()) {
            QRegularExpressionMatch match = rxIterator.next();
            QString matchStr = match.captured(0);
            QString matchSubStr = match.captured(1);
            //qDebug("%s -> %s", matchSubStr.toStdString().c_str(), getPlaceholderValue(matchSubStr,
            //requestDoc).toStdString().c_str());
            replacements.insert({matchStr, getPlaceholderValue(matchSubStr, requestDoc)});
        }
    }

    // replace placeholders
    for (const auto& response : responses) {
        QString responseStr(response);
        for (const auto& replacement : replacements) {
            responseStr = responseStr.replace(replacement.first, replacement.second);
        }
        //qDebug("%s", responseStr.toStdString().c_str());
        retVal.push_back(responseStr.toUtf8());
    }
    return retVal;
}

void MockDeviceControl::getExpectedValues(QString firmwarePath)
{
    QFile firmware(firmwarePath);

    if (firmware.open(QIODevice::ReadOnly)) {
        expectedChunksCount_ = static_cast<int>((firmware.size() - 1 + mock_firmware_constants::CHUNK_SIZE) / mock_firmware_constants::CHUNK_SIZE); //Get expected chunks count

        firmware.seek(0);
        while (firmware.atEnd() == false) {
            int chunkSize = mock_firmware_constants::CHUNK_SIZE;
            qint64 remainingFileSize = firmware.size() - firmware.pos();

            if (remainingFileSize <= mock_firmware_constants::CHUNK_SIZE) {
                chunkSize = static_cast<int>(remainingFileSize);
            }
            QVector<quint8> chunk(chunkSize);
            qint64 bytesRead = firmware.read(reinterpret_cast<char*>(chunk.data()), chunkSize);

            expectedChunkSize_.append(bytesRead);

            size_t firmwareBase64Size = base64::encoded_size(static_cast<size_t>(bytesRead));
            QByteArray firmwareBase64;
            firmwareBase64.resize(static_cast<int>(firmwareBase64Size));
            base64::encode(firmwareBase64.data(), chunk.data(), static_cast<size_t>(bytesRead));

            expectedChunkCrc_.append((crc16::buypass(chunk.data(), static_cast<uint32_t>(bytesRead)))); //Get expected chunk crc

            if (firmwareBase64.isNull() == false || firmwareBase64.isEmpty() == false) {
                expectedChunkData_.append(firmwareBase64);
            }
        }
    }
    else {
        qCCritical(logCategoryDeviceMock) << "Cannot open mock firmware";
    }
}

void MockDeviceControl::createMockFirmware()
{
    mockFirmware_.createNativeFile(QStringLiteral("mockFirmware"));
    mockFirmware_.setAutoRemove(true);

    if (mockFirmware_.open() == false) {
        qCCritical(logCategoryDeviceMock) << "Cannot open mock firmware";
    } else {
        QTextStream mockFirmwareOut(&mockFirmware_);
        mockFirmwareOut << mock_firmware_constants::mockFirmwareData;
        mockFirmwareOut.flush();
        mockFirmware_.close();
        qCDebug(logCategoryDeviceMock) << "Mock firmware file prepared with the size of" << mockFirmware_.size() << "bytes";
    }
}

} // namespace strata::device
