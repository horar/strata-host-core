#include <Device/Mock/MockDeviceControl.h>

#include "logging/LoggingQtCategories.h"

namespace strata::device::mock {

MockDeviceControl::MockDeviceControl(QObject *parent)
    : QObject(parent)
{
}

MockDeviceControl::~MockDeviceControl()
{
}

bool MockDeviceControl::mockIsBootloader() const
{
    return isBootloader_;
}

bool MockDeviceControl::mockIsLegacy() const
{
    return isLegacy_;
}

MockCommand MockDeviceControl::mockGetCommand() const
{
    return command_;
}

MockResponse MockDeviceControl::mockGetResponse() const
{
    return response_;
}

bool MockDeviceControl::mockSetLegacy(bool legacy)
{
    if (isLegacy_ != legacy) {
        isLegacy_ = legacy;
        qCDebug(logCategoryMockDevice) << "Configured legacy mode to" << isLegacy_;
        return true;
    }
    qCDebug(logCategoryMockDevice) << "Legacy mode already configured to" << isLegacy_;
    return false;
}

bool MockDeviceControl::mockSetCommand(MockCommand command)
{
    if (command_ != command) {
        command_ = command;
        qCDebug(logCategoryMockDevice) << "Configured command from command-response pair to"
                                       << command_<< ":" << response_;
        return true;
    }
    qCDebug(logCategoryMockDevice) << "Command from command-response pair already configured to"
                                   << command_<< ":" << response_;
    return false;
}

bool MockDeviceControl::mockSetResponse(MockResponse response)
{
    if (response_ != response) {
        response_ = response;
        qCDebug(logCategoryMockDevice) << "Configured response command-response pair to"
                                       << command_<< ":" << response_;
        return true;
    }
    qCDebug(logCategoryMockDevice) << "Response from command-response pair already configured to"
                                   << command_<< ":" << response_;
    return false;
}

bool MockDeviceControl::mockSetCommandForResponse(MockCommand command, MockResponse response)
{
    if ((command_ != command) || (response_ != response)) {
        command_ = command;
        response_ = response;
        qCDebug(logCategoryMockDevice) << "Configured command-response pair to"
                                       << command_<< ":" << response_;
        return true;
    }
    qCDebug(logCategoryMockDevice) << "Command-response pair already configured to"
                                   << command_<< ":" << response_;
    return false;
}

std::vector<QByteArray> MockDeviceControl::getResponses(QByteArray request)
{
    rapidjson::Document requestDoc;
    rapidjson::ParseResult parseResult = requestDoc.Parse(request.toStdString().c_str());
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
            break;
        case MockCommand::request_platform_id:
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
        default:
            break;
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
    }  // add other namespaces as required in the future (e.g. refer to mock variables)
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

} // namespace strata::device::mock
