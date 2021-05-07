#include <Mock/MockDeviceControl.h>

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

std::vector<QByteArray> MockDeviceControl::getResponses(const QByteArray& request) {
    auto responses = getRawResponses(request);
    auto normalizedResponses = normalizeResponses(responses);

    return normalizedResponses;
}

std::vector<QByteArray> MockDeviceControl::normalizeResponses(const std::vector<QByteArray>& responses) const {
    std::vector<QByteArray> retVal;
    for (const QByteArray& response : responses) {
        QJsonParseError error;
        QJsonDocument document = QJsonDocument::fromJson(response, &error);

        if (document.isNull() == true) {
            qCWarning(logCategoryDeviceMock) << "Unable to normalize message" << response << ":" << error.errorString();

            // Strata commands must end with new line character ('\n')
            if (response.endsWith('\n') == false) {
                QByteArray normalizedResponse(response);
                normalizedResponse.append('\n');
                retVal.push_back(normalizedResponse);
                continue;
            }

            retVal.push_back(response);
            continue;
        }

        retVal.push_back(document.toJson(QJsonDocument::Compact).append('\n'));
    }

    return retVal;
}

std::vector<QByteArray> MockDeviceControl::getRawResponses(const QByteArray& request)
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
        MockCommand recievedCommand = MockCommand::all_commands;

        if (0 == cmd.compare("get_firmware_info")) {
            recievedCommand = MockCommand::get_firmware_info;
        }
        if (0 == cmd.compare("request_platform_id")) {
            recievedCommand = MockCommand::request_platform_id;
        }
        if (0 == cmd.compare("start_bootloader")) {
            recievedCommand = MockCommand::start_bootloader;
        }
        if (0 == cmd.compare("start_application")) {
            recievedCommand = MockCommand::start_application;
        }
        if (0 == cmd.compare("start_flash_firmware")) {
            recievedCommand = MockCommand::start_flash_firmware;
        }
        if (0 == cmd.compare("flash_firmware")) {
            recievedCommand = MockCommand::flash_firmware;
        }
        if (0 == cmd.compare("start_flash_bootloader")) {
            recievedCommand = MockCommand::start_flash_bootloader;
        }
        if (0 == cmd.compare("flash_bootloader")) {
            recievedCommand = MockCommand::flash_bootloader;
        }

        retVal.push_back(test_commands::ack);

        bool customResponse = (command_ == recievedCommand) || (command_ == MockCommand::all_commands);
        if (customResponse) {
            if (response_ == MockResponse::nack) {
                retVal.pop_back();  // remove ack
                retVal.push_back(test_commands::nack_command_not_found);
                return replacePlaceholders(retVal, requestDoc);
            } else if (response_ == MockResponse::no_JSON) {
                retVal.push_back(test_commands::no_JSON_response);
                return replacePlaceholders(retVal, requestDoc);
            }
        }

        switch (recievedCommand) {
        case MockCommand::get_firmware_info:
            if (version_ == MockVersion::version1) {
                if (isLegacy_) {
                    retVal.pop_back();  // remove ack
                    retVal.push_back(test_commands::nack_command_not_found);
                } else if (customResponse) {
                    switch(response_) {
                    case MockResponse::no_payload: {
                        retVal.push_back(test_commands::get_firmware_info_response_no_payload);
                    } break;
                    case MockResponse::invalid: {
                        retVal.push_back(test_commands::get_firmware_info_response_invalid);
                    } break;
                    default: {
                        retVal.push_back(test_commands::get_firmware_info_response);
                    } break;
                    }
                } else {
                    retVal.push_back(test_commands::get_firmware_info_response);
                }
            } else if (version_ == MockVersion::version2) {
                if (customResponse) {
                    switch(response_) {
                    case MockResponse::embedded_app:
                    case MockResponse::assisted_app:
                    case MockResponse::assisted_no_board: {
                        retVal.push_back(test_commands::get_firmware_info_response_ver2_application);
                    } break;
                    case MockResponse::embedded_btloader:
                    case MockResponse::assisted_btloader:{
                        retVal.push_back(test_commands::get_firmware_info_response_ver2_bootloader);
                    } break;
                    case MockResponse::no_payload: {
                        retVal.push_back(test_commands::get_firmware_info_response_no_payload);
                    } break;
                    case MockResponse::invalid:{
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
        case MockCommand::request_platform_id:
            if (version_ == MockVersion::version1) {
                if (isBootloader_) {
                    if (customResponse) {
                        switch(response_) {
                        case MockResponse::no_payload: {
                            retVal.push_back(test_commands::request_platform_id_response_bootloader_no_payload);
                        } break;
                        case MockResponse::invalid: {
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
                        case MockResponse::no_payload: {
                            retVal.push_back(test_commands::request_platform_id_response_no_payload);
                        } break;
                        case MockResponse::invalid: {
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
            } else if (version_ == MockVersion::version2) {
                if (customResponse) {
                    switch(response_) {
                    case MockResponse::embedded_app: {
                        retVal.push_back(test_commands::request_platform_id_response_ver2_embedded);
                    } break;
                    case MockResponse::assisted_app: {
                        retVal.push_back(test_commands::request_platform_id_response_ver2_assisted);
                    } break;
                    case MockResponse::assisted_no_board: {
                        retVal.push_back(test_commands::request_platform_id_response_ver2_assisted_without_board);
                    } break;
                    case MockResponse::embedded_btloader: {
                        retVal.push_back(test_commands::request_platform_id_response_ver2_embedded_bootloader);
                    } break;
                    case MockResponse::assisted_btloader:{
                        retVal.push_back(test_commands::request_platform_id_response_ver2_assisted_bootloader);
                    } break;
                    case MockResponse::no_payload: {
                        retVal.push_back(test_commands::request_platform_id_response_no_payload);
                    } break;
                    case MockResponse::invalid: {
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
        case MockCommand::start_bootloader:
            isBootloader_ = true;
            if (customResponse) {
                switch(response_) {
                case MockResponse::no_payload: {
                    retVal.push_back(test_commands::start_bootloader_response_no_payload);
                } break;
                case MockResponse::invalid: {
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
        case MockCommand::start_application:
            isBootloader_ = false;
            if (customResponse) {
                switch(response_) {
                case MockResponse::no_payload: {
                    retVal.push_back(test_commands::start_application_response_no_payload);
                } break;
                case MockResponse::invalid: {
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

        case MockCommand::flash_firmware:
            if (customResponse) {
                switch (response_) {
                case MockResponse::flash_resend_chunk: {
                    retVal.push_back(test_commands::flash_firmware_response_resend_chunk);
                } break;
                case MockResponse::flash_memory_error: {
                    retVal.push_back(test_commands::flash_firmware_response_memory_error);
                } break;
                case MockResponse::flash_invalid_cmd_sequence: {
                    retVal.push_back(test_commands::flash_firmware_response_invalid_cmd_sequence);
                } break;
                case MockResponse::flash_invalid_value: {
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

        case MockCommand::flash_bootloader:
            retVal.push_back(test_commands::flash_bootloader_response);
            break;

        case MockCommand::start_flash_firmware:
            if (customResponse) {
                switch (response_) {
                case MockResponse::start_flash_firmware_invalid: {
                    retVal.push_back(test_commands::start_flash_firmware_response_invalid);
                } break;
                default: {
                    retVal.push_back(test_commands::start_flash_firmware_response);
                } break;
                }
            } else {
            retVal.push_back(test_commands::start_flash_firmware_response);
            }
            break;

        case MockCommand::start_flash_bootloader:
            retVal.push_back(test_commands::start_flash_bootloader_response);
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
        // fallthrough
    } // add other namespaces as required in the future (e.g. refer to mock variables)
    //QFAIL_(("Problem replacing placeholder <" + placeholder + ">").toStdString().c_str());
    return placeholder;  // fallback, return the value as is
}

std::vector<QByteArray> MockDeviceControl::replacePlaceholders(const std::vector<QByteArray> &responses,
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
            QString matchStr = match.captured().mid(2).chopped(1);
            // qDebug("%s -> %s", matchStr.toStdString().c_str(), getPlaceholderValue(matchStr,
            // requestDoc).toStdString().c_str());
            replacements.insert({matchStr, getPlaceholderValue(matchStr, requestDoc)});
        }
    }

    // replace placeholders
    for (const auto& response : responses) {
        QString responseStr(response);
        for (const auto& replacement : replacements) {
            responseStr = responseStr.replace("{$" + replacement.first + "}", replacement.second);
        }
        // qDebug("%s", responseStr.toStdString().c_str());
        retVal.push_back(responseStr.toUtf8());
    }
    return retVal;
}

} // namespace strata::device
