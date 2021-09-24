/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <Mock/MockDeviceControl.h>
#include <QFile>
#include <QDir>
#include <QTimer>
#include <Buypass.h>
#include <CodecBase64.h>
#include <QMetaEnum>
#include <QRandomGenerator>
#include <QDataStream>

#include "logging/LoggingQtCategories.h"

namespace strata::device {

MockDeviceControl::MockDeviceControl(const bool saveMessages, QObject *parent)
    : QObject(parent),
      saveMessages_(saveMessages),
      mockFirmware_(QDir(QDir::tempPath()).filePath(QStringLiteral("mockFirmware")))
{
    initializeDefaultResponses();
}

MockDeviceControl::~MockDeviceControl()
{
}

int MockDeviceControl::writeMessage(const QByteArray &msg)
{
    ++messagesSent_;
    if ((emitErrorOnNthMessage_ != 0) && (messagesSent_ % emitErrorOnNthMessage_ == 0)) {
        qCDebug(logCategoryDeviceMock) << "Write configured to fail on following message:" << msg;
        return false;
    }

    if (saveMessages_) {
        if (recordedMessages_.size() >= MAX_STORED_MESSAGES) {
            qCWarning(logCategoryDeviceMock) << "Maximum number (" << MAX_STORED_MESSAGES
                                             << ") of stored messages reached";
            recordedMessages_.pop_front();
        }

        recordedMessages_.push_back(msg);
    }

    return msg.size();
}

void MockDeviceControl::emitResponses(const QByteArray& msg)
{
    auto responses = getResponses(msg);
    QTimer::singleShot(
                10, this, [=]() {
        for (const QByteArray& response : responses) { // deferred emit (if emitted in the same loop, may cause trouble)
            emit messageDispatched(response);
        }
    });
}

std::vector<QByteArray> MockDeviceControl::getRecordedMessages() const
{
    // copy the result, recordedMessages_ may change over time
    std::vector<QByteArray> result(recordedMessages_.size());
    std::copy(recordedMessages_.begin(), recordedMessages_.end(), result.begin());

    return result;
}

std::vector<QByteArray>::size_type MockDeviceControl::getRecordedMessagesCount() const
{
    return recordedMessages_.size();
}

void MockDeviceControl::clearRecordedMessages()
{
    recordedMessages_.clear();
}

bool MockDeviceControl::isOpenEnabled() const
{
    return isOpenEnabled_;
}

bool MockDeviceControl::isAutoResponse() const
{
    return autoResponse_;
}

bool MockDeviceControl::isBootloader() const
{
    return isBootloader_;
}

bool MockDeviceControl::isFirmwareEnabled() const
{
    return isFirmwareEnabled_;
}

bool MockDeviceControl::isErrorOnCloseSet() const
{
    return emitErrorOnClose_;
}

bool MockDeviceControl::isErrorOnNthMessageSet() const
{
    return emitErrorOnNthMessage_;
}

MockResponse MockDeviceControl::getResponseForCommand(MockCommand command) const
{
    auto iter = responses_.find(command);
    if (iter != responses_.end()) {
        return iter->second;
    }

    return MockResponse::Nack;
}

MockVersion MockDeviceControl::getVersion() const
{
    return version_;
}

bool MockDeviceControl::setOpenEnabled(bool enabled)
{
    if (isOpenEnabled_ != enabled) {
        isOpenEnabled_ = enabled;
        qCDebug(logCategoryDeviceMock) << "Configured open enabled to" << isOpenEnabled_;
        return true;
    }
    qCDebug(logCategoryDeviceMock) << "Open enabled already configured to" << isOpenEnabled_;
    return false;
}

bool MockDeviceControl::setAutoResponse(bool autoResponse)
{
    if (autoResponse_ != autoResponse) {
        autoResponse_ = autoResponse;
        qCDebug(logCategoryDeviceMock) << "Configured auto-response to" << autoResponse_;
        return true;
    }
    qCDebug(logCategoryDeviceMock) << "Auto-response already configured to" << autoResponse_;
    return false;
}

bool MockDeviceControl::setSaveMessages(bool saveMessages)
{
    if (saveMessages_ != saveMessages) {
        saveMessages_ = saveMessages;
        qCDebug(logCategoryDeviceMock) << "Configured save-messages mode to" << saveMessages_;
        return true;
    }
    qCDebug(logCategoryDeviceMock) << "Save-messages already configured to" << saveMessages_;
    return false;
}

bool MockDeviceControl::setResponseForCommand(MockResponse response, MockCommand command)
{
    auto iter = responses_.find(command);
    if ((iter == responses_.end()) || (iter->second != response)) {
        responses_[command] = response;
        qCDebug(logCategoryDeviceMock) << "Configured command-response pair to"
                                       << command << ":" << response;
        return true;
    }
    qCDebug(logCategoryDeviceMock) << "Command-response pair already configured to"
                                   << command << ":" << response;
    return false;
}

bool MockDeviceControl::setVersion(MockVersion version)
{
    if (version_ != version) {
        version_ = version;
        qCDebug(logCategoryDeviceMock) << "Configured version to" << version_;
        initializeDefaultResponses();
        return true;
    }
    qCDebug(logCategoryDeviceMock) << "Version already configured to" << version_;
    return false;
}

bool MockDeviceControl::setAsBootloader(bool isBootloader)
{
    if (isBootloader_ != isBootloader) {
        isBootloader_ = isBootloader;
        qCDebug(logCategoryDeviceMock) << "Configured is bootloader to" << isBootloader_;
        return true;
    }
    qCDebug(logCategoryDeviceMock) << "Is bootloader already configured to" << isBootloader_;
    return false;
}

bool MockDeviceControl::setFirmwareEnabled(bool enabled)
{
    if (isFirmwareEnabled_ != enabled) {
        isFirmwareEnabled_ = enabled;
        qCDebug(logCategoryDeviceMock) << "Configured mock firmware to" << isFirmwareEnabled_;
        return true;
    }
    qCDebug(logCategoryDeviceMock) << "Mock firmware already configured to" << isFirmwareEnabled_;
    return false;
}

bool MockDeviceControl::setErrorOnClose(bool enabled) {
    if (emitErrorOnClose_ != enabled) {
        emitErrorOnClose_ = enabled;
        qCDebug(logCategoryDeviceMock) << "Configured emit error on close to" << emitErrorOnClose_;
        return true;
    }
    qCDebug(logCategoryDeviceMock) << "Emit error on close already configured to" << emitErrorOnClose_;
    return false;
}

bool MockDeviceControl::setWriteErrorOnNthMessage(unsigned messageNumber) {
    messagesSent_ = 0;
    if (emitErrorOnNthMessage_ != messageNumber) {
        emitErrorOnNthMessage_ = messageNumber;
        qCDebug(logCategoryDeviceMock) << "Configured emit error on message sent to" << emitErrorOnNthMessage_;
        return true;
    }
    qCDebug(logCategoryDeviceMock) << "Emit error on message sent already configured to" << emitErrorOnNthMessage_;
    return false;
}

void MockDeviceControl::initializeDefaultResponses()
{
    if (responses_.empty() == false) {
        qCDebug(logCategoryDeviceMock) << "Reinitializing responses for commands version:" << version_;
    }

    responses_.clear();
    QList<MockCommand> supportedCommands = mockSupportedCommands(version_);
    foreach(auto command, supportedCommands) {
        responses_.insert({command, MockResponse::Normal});
    }
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
    if (qCmd->IsString() == false) {
        return std::vector<QByteArray>({test_commands::nack_badly_formatted_json});
    }

    MockCommand recievedCommand;
    std::string cmd = qCmd->GetString();
    if (mockCommandConvertStringToEnum(cmd, recievedCommand) == false) {
        qCWarning(logCategoryDeviceMock) << "Unknown command received:" << cmd.c_str();
        retVal.push_back(test_commands::nack_command_not_found);
        return replacePlaceholders(retVal, requestDoc);
    }

    MockResponse response = getResponseForCommand(recievedCommand);

    if (response == MockResponse::Nack) {
        retVal.push_back(test_commands::nack_command_not_found);
        return replacePlaceholders(retVal, requestDoc);
    }

    retVal.push_back(test_commands::ack);

    if (response == MockResponse::No_JSON) {
        retVal.push_back(test_commands::no_JSON_response);
        return replacePlaceholders(retVal, requestDoc);
    }

    switch (recievedCommand) {
    case MockCommand::Request_platform_id: {
        if (version_ == MockVersion::Version_1) {
            switch(response) {
            case MockResponse::Platform_config_bootloader:
            case MockResponse::Platform_config_bootloader_invalid: {
                isBootloader_ = true;
            } break;
            default: {
                isBootloader_ = false;
            } break;
            }
        }
    } break;
    case MockCommand::Start_bootloader: {
        isBootloader_ = true;
    } break;
    case MockCommand::Start_application: {
        isBootloader_ = false;
    } break;
    default: break;
    }

    auto versionIter = test_commands::mockResponsesMap.constFind(version_);
    if (versionIter != test_commands::mockResponsesMap.constEnd()) {
        auto commandIter = versionIter.value().constFind(recievedCommand);
        if (commandIter != versionIter.value().constEnd()) {
            auto responseIter = commandIter.value().constFind(response);
            if (responseIter != commandIter.value().constEnd()) {
                retVal.push_back(responseIter.value());
            }
        }
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

    else if (0 == placeholderNamespace.compare("firmware") && placeholderSplit.length() >= 1) {
        return getFirmwareValue(placeholder);
    }

    else if (0 == placeholderNamespace.compare("chunk") && placeholderSplit.length() >= 1) {
        return getChunksValue(placeholder);
    }// fallthrough
    // add other namespaces as required in the future (e.g. refer to mock variables)
    //qWarning() << (("Problem replacing placeholder <" + placeholder + ">").toStdString().c_str());
    return placeholder;  // fallback, return the value as is
}


QString MockDeviceControl::getFirmwareValue(const QString placeholder)
{
    if (isFirmwareEnabled_) {
        if (mockFirmware_.exists() == false) {
            createMockFirmware();
            getExpectedValues(mockFirmware_.fileName());
        }
    } else {
        if (mockFirmware_.exists() == true) {
            removeMockFirmware();
        }
    }

    if (mockFirmware_.exists()) {
        actualChunk_ = 0; //begin of backup_firmware
        payloadCount_ = 0;

        if (placeholder == "firmware.size") {
            return QString::number(mockFirmware_.size());
        }
        if (placeholder == "firmware.chunks") {
            return QString::number(expectedChunksCount_);
        }
    } else {
        if (placeholder == "firmware.size") {
            return QString::number(0);
        }
        if (placeholder == "firmware.chunks") {
            return QString::number(0);
        }
    }
    return placeholder;  // fallback, return the value as is
}

QString MockDeviceControl::getChunksValue(const QString placeholder)
{
    if (actualChunk_ < expectedChunksCount_ && mockFirmware_.exists()) {
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
    } else {
        qCCritical(logCategoryDeviceMock) << "Cannot open mock firmware";
    }
}

QByteArray MockDeviceControl::generateMockFirmware(bool isBootloader)
{
    const quint32 bufferSize = isBootloader ?
                mock_firmware_constants::bootloaderBufferSize : mock_firmware_constants::firmwareBufferSize;

    auto buffer = std::make_unique<quint32[]>(bufferSize);
    std::seed_seq sseq{1,2,3};
    QRandomGenerator generator(sseq);
    generator.fillRange(buffer.get(), bufferSize);

    QByteArray generatedFirmware;
    QDataStream stream(&generatedFirmware, QIODevice::WriteOnly);
    for (quint32 i = 0; i < bufferSize; i++) {
        stream << buffer[i];
    }
    return generatedFirmware;
}

void MockDeviceControl::createMockFirmware()
{
    if (mockFirmware_.open() == false) {
        qCCritical(logCategoryDeviceMock) << "Cannot open mock firmware";
    } else {
        QDataStream mockFirmwareOut(&mockFirmware_);
        mockFirmwareOut << generateMockFirmware();
        mockFirmware_.close();
        qCDebug(logCategoryDeviceMock) << "Mock firmware file prepared with the size of" << mockFirmware_.size() << "bytes";
    }
}

void MockDeviceControl::removeMockFirmware()
{
    if (mockFirmware_.exists() == false) {
        qCCritical(logCategoryDeviceMock) << "No mock firmware for removal";
    } else {
        mockFirmware_.remove();
        qCDebug(logCategoryDeviceMock) << "Mock firmware file removed";
    }
}

} // namespace strata::device
