#pragma once

#include <Mock/MockDeviceConstants.h>
#include <Device.h>
#include <rapidjson/document.h>
#include <QString>
#include <QVector>
#include <QTemporaryFile>
#include <list>

namespace strata::device {

class MockDeviceControl : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(MockDeviceControl)

public:
    explicit MockDeviceControl(const bool saveMessages, QObject *parent = nullptr);
    ~MockDeviceControl() override;

    int writeMessage(const QByteArray &msg);
    void emitResponses(const QByteArray& msg);

    std::vector<QByteArray> getRecordedMessages() const;
    std::vector<QByteArray>::size_type getRecordedMessagesCount() const;
    void clearRecordedMessages();

    bool isOpenEnabled() const;
    bool isLegacy() const;
    bool isAutoResponse() const;
    bool isBootloader() const;
    bool isFirmwareEnabled() const;
    MockCommand getCommand() const;
    MockResponse getResponse() const;
    MockVersion getVersion() const;

    bool setOpenEnabled(bool enabled);
    bool setLegacy(bool legacy);
    bool setAutoResponse(bool autoResponse);
    bool setSaveMessages(bool saveMessages);
    bool setCommand(MockCommand command);
    bool setResponse(MockResponse response);
    bool setResponseForCommand(MockResponse response, MockCommand command);
    bool setVersion(MockVersion version);
    bool setAsBootloader(bool isBootloader);
    bool setFirmwareEnabled(bool enabled);

signals:
    /**
     * Emitted when message was sent from device.
     * @param msg acquired message from device
     */
    void messageDispatched(QByteArray msg);

    /**
     * Emitted when error occured.
     * @param errCode error code
     * @param msg error description
     */
    void errorOccurred(Device::ErrorCode errCode, QString msg);

private:
    std::vector<QByteArray> getResponses(const QByteArray& request);

    const std::vector<QByteArray> replacePlaceholders(const std::vector<QByteArray> &responses,
                                                      const rapidjson::Document &requestDoc);
    QString getPlaceholderValue(const QString placeholder,
                                const rapidjson::Document &requestDoc);
    QString getFirmwareValue(const QString placeholder);
    QString getChunksValue(const QString placeholder);

    void createMockFirmware();
    void removeMockFirmware();
    void getExpectedValues(QString firmwarePath);

private:
    bool autoResponse_ = true;
    bool saveMessages_ = false;
    bool isOpenEnabled_ = true;
    bool isLegacy_ = false;     // very old board without 'get_firmware_info' command support
    bool isBootloader_ = false;
    bool isFirmwareEnabled_ = true;
    MockCommand command_ = MockCommand::Any_command;
    MockResponse response_ = MockResponse::Normal;
    MockVersion version_ = MockVersion::Version_1;

    // variables used to store mock firmware's expected values
    int payloadCount_ = 0;
    QTemporaryFile mockFirmware_;
    int actualChunk_ = 0;
    int expectedChunksCount_ = 0;
    QVector<quint64> expectedChunkSize_;
    QVector<QByteArray> expectedChunkData_;
    QVector<quint16> expectedChunkCrc_;

    // variables used to store incoming messages and data processed from them
    std::list<QByteArray> recordedMessages_;
};

} // namespace strata::device
