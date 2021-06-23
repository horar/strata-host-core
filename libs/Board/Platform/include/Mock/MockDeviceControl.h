#pragma once

#include <Mock/MockDeviceConstants.h>
#include <Device.h>
#include <rapidjson/document.h>
#include <QString>
#include <QVector>
#include <QTemporaryFile>
#include <list>
#include <map>

namespace strata::device {

typedef std::map<MockCommand, MockResponse> MockCommandResponseMap;

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
    bool isAutoResponse() const;
    bool isBootloader() const;
    bool isFirmwareEnabled() const;
    bool isErrorOnCloseSet() const;
    bool isErrorOnNthMessageSet() const;
    MockResponse getResponseForCommand(MockCommand command) const;
    MockVersion getVersion() const;

    bool setOpenEnabled(bool enabled);
    bool setAutoResponse(bool autoResponse);
    bool setSaveMessages(bool saveMessages);
    bool setResponseForCommand(MockResponse response, MockCommand command);
    bool setVersion(MockVersion version);
    bool setAsBootloader(bool isBootloader);
    bool setFirmwareEnabled(bool enabled);
    bool setErrorOnClose(bool enabled);
    bool setErrorOnNthMessage(unsigned messageNumber);

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
    void initializeResponses();

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
    bool isBootloader_ = false;
    bool isFirmwareEnabled_ = true;
    bool emitErrorOnClose_ = false;
    unsigned emitErrorOnNthMessage_ = 0;
    MockCommandResponseMap responses_;
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
    unsigned messagesSent_ = 0;
};

} // namespace strata::device
