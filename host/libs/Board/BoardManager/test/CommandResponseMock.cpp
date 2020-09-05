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

    retVal.push_back(test_commands::ack);

    auto *qCmd = &requestDoc["cmd"];
    if (qCmd->IsString()) {
        std::string cmd = qCmd->GetString();
        if (0 == cmd.compare("get_firmware_info")) {
            retVal.push_back(test_commands::get_firmware_info_response);
        } else if (0 == cmd.compare("request_platform_id")) {
            if (isBootloader_) {
                retVal.push_back(test_commands::request_platform_id_response_bootloader);
            } else {
                retVal.push_back(test_commands::request_platform_id_response);
            }
        } else if (0 == cmd.compare("start_bootloader")) {
            isBootloader_ = true;
            retVal.push_back(test_commands::start_bootloader_response);
        } else if (0 == cmd.compare("start_application")) {
            isBootloader_ = false;
            retVal.push_back(test_commands::start_application_response);
        }
    }
    return replacePlaceholders(retVal, requestDoc);
}

CommandResponseMock::CommandResponseMock()
{
}
