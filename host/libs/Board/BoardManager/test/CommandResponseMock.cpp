#include "CommandResponseMock.h"
#include "QtTest.h"

QString CommandResponseMock::getPlaceholderValue(const QString placeholder,
                                                 const rapidjson::Document &requestDoc)
{
    QStringList placeholderSplit = placeholder.split(".");
    QString placeholderNamespace = placeholderSplit[0];
    placeholderSplit.removeAt(0);

    if (0 == placeholderNamespace.compare("request") && placeholderSplit.length() >= 1) {
        const rapidjson::Value *targetDocumentNode = &requestDoc;
        for (auto placeholderPart : placeholderSplit) {
            if (!targetDocumentNode->IsObject() ||
                !targetDocumentNode->HasMember(placeholderPart.toStdString().c_str())) {
                QFAIL_(
                    ("Problem replacing placeholder <" + placeholder + ">").toStdString().c_str());
                return placeholder;
            }
            targetDocumentNode = &(*targetDocumentNode)[placeholderPart.toStdString().c_str()];
        }

        if (targetDocumentNode->IsString()) {
            return targetDocumentNode->GetString();
        }
        // fallthrough
    }  // add other namespaces as required in the future (e.g. refer to mock variables)
    QFAIL_(("Problem replacing placeholder <" + placeholder + ">").toStdString().c_str());
    return placeholder;  // fallback, return the value as is
}

std::vector<QByteArray> CommandResponseMock::replacePlaceholders(
    const std::vector<QByteArray> &responses, const rapidjson::Document &requestDoc)
{
    std::vector<QByteArray> retVal;
    std::map<QString, QString> replacements;

    // find and resolve placeholders
    for (auto response : responses) {
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
    for (auto response : responses) {
        QString responseStr(response);
        for (auto replacement : replacements) {
            responseStr = responseStr.replace("{$" + replacement.first + "}", replacement.second);
        }
        // qDebug("%s", responseStr.toStdString().c_str());
        retVal.push_back(responseStr.toUtf8());
    }
    return retVal;
}

std::vector<QByteArray> CommandResponseMock::getResponses(QByteArray request)
{
    rapidjson::Document requestDoc;
    rapidjson::ParseResult parseResult = requestDoc.Parse(request.toStdString().c_str());
    std::vector<QByteArray> retVal;
    if (parseResult.IsError()) {
        return std::vector<QByteArray>({test_commands::nack_badly_formatted_json});
    }

    if (response_ == MockResponse::nack) {
        retVal.push_back(test_commands::nack_command_not_found);
        return replacePlaceholders(retVal, requestDoc);
    } else {
        retVal.push_back(test_commands::ack);
    }

    auto *qCmd = &requestDoc["cmd"];
    if (qCmd->IsString()) {

        std::string cmd = qCmd->GetString();
        CommandResponseMock::Command recievedCommand;

        if (0 == cmd.compare("get_firmware_info")) {
            recievedCommand = Command::get_firmware_info;
        }
        if (0 == cmd.compare("request_platform_id")) {
            recievedCommand = Command::request_platform_id;
        }
        if (0 == cmd.compare("start_bootloader")) {
            recievedCommand = Command::start_bootloader;
        }
        if (0 == cmd.compare("start_application")) {
            recievedCommand = Command::start_application;
        }

        switch (recievedCommand) {
        case Command::get_firmware_info:

            if (version_ == Version::version1) {
                if (isLegacy_) {
                    retVal.pop_back();  // remove ack
                    retVal.push_back(test_commands::nack_command_not_found);
                } else if (response_ == MockResponse::no_payload && recievedCommand == command_) {
                    retVal.push_back(test_commands::get_firmware_info_response_no_payload);
                } else if (response_ == MockResponse::no_JSON) {
                    retVal.push_back(test_commands::no_JSON_response);
                } else if (response_ == MockResponse::invalid && recievedCommand == command_) {
                    retVal.push_back(test_commands::get_firmware_info_response_invalid);
                } else {
                    retVal.push_back(test_commands::get_firmware_info_response);
                }
            }

            if (version_ == Version::version2) {
                if (response_ == MockResponse::embedded_app || response_ == MockResponse::assisted_app || response_ == MockResponse::assisted_no_board) {
                    retVal.push_back(test_commands::get_firmware_info_response_ver2_application);
                } else if ((response_ == MockResponse::embedded_btloader || response_ == MockResponse::assisted_btloader)) {
                    retVal.push_back(test_commands::get_firmware_info_response_ver2_bootloader);
                } else if (response_ == MockResponse::invalid) {
                    retVal.push_back(test_commands::get_firmware_info_response_ver2_invalid);
                }
            }
            break;

        case Command::request_platform_id:

            if (version_ == Version::version1) {
                if (isBootloader_) {
                    if (response_ == MockResponse::no_payload && recievedCommand == command_) {
                        retVal.push_back(test_commands::request_platform_id_response_bootloader_no_payload);
                    } else if (response_ == MockResponse::invalid && recievedCommand == command_) {
                        retVal.push_back(test_commands::request_platform_id_response_bootloader_invalid);
                    } else {
                        retVal.push_back(test_commands::request_platform_id_response_bootloader);
                    }
                } else {
                    if (response_ == MockResponse::no_payload && recievedCommand == command_) {
                        retVal.push_back(test_commands::request_platform_id_response_no_payload);
                    } else if (response_ == MockResponse::invalid && recievedCommand == command_) {
                        retVal.push_back(test_commands::request_platform_id_response_invalid);
                    } else {
                        retVal.push_back(test_commands::request_platform_id_response);
                    }
                }
            }

            if (version_ == Version::version2) {
                if (response_ == MockResponse::embedded_app) {
                    retVal.push_back(test_commands::request_platform_id_response_ver2_embedded);
                } else if (response_ == MockResponse::assisted_app) {
                    retVal.push_back(test_commands::request_platform_id_response_ver2_assisted);
                } else if (response_ == MockResponse::assisted_no_board) {
                    retVal.push_back(test_commands::request_platform_id_response_ver2_assisted_without_board);
                } else if (response_ == MockResponse::embedded_btloader) {
                    retVal.push_back(test_commands::request_platform_id_response_ver2_embedded_bootloader);
                } else if (response_ == MockResponse::assisted_btloader) {
                    retVal.push_back(test_commands::request_platform_id_response_ver2_assisted_bootloader);
                }
            }
            break;

        case Command::start_bootloader:
            isBootloader_ = true;
            if (response_ == MockResponse::no_payload && command_ == recievedCommand) {
                retVal.push_back(test_commands::start_bootloader_response_no_payload);
            } else if (response_ == MockResponse::invalid && command_ == recievedCommand) {
                retVal.push_back(test_commands::start_bootloader_response_invalid);
            } else {
                retVal.push_back(test_commands::start_bootloader_response);
            }
            break;

        case Command::start_application:
            isBootloader_ = false;
            if (response_ == MockResponse::no_payload && command_ == recievedCommand) {
                retVal.push_back(test_commands::start_application_response_no_payload);
            } else if (response_ == MockResponse::invalid && command_ == recievedCommand) {
                retVal.push_back(test_commands::start_application_response_invalid);
            } else {
                retVal.push_back(test_commands::start_application_response);
            }
            break;

        default:
            break;
        }
    }
    return replacePlaceholders(retVal, requestDoc);
}

CommandResponseMock::CommandResponseMock()
{
}
