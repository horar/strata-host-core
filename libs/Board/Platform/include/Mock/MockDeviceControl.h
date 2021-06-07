#pragma once

#include <Mock/MockDeviceConstants.h>
#include <rapidjson/document.h>
#include <QString>
#include <QVector>
#include <QTemporaryFile>

namespace strata::device {

class MockDeviceControl : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(MockDeviceControl)

public:
    explicit MockDeviceControl(QObject *parent = nullptr);
    ~MockDeviceControl() override;

    std::vector<QByteArray> getResponses(const QByteArray& request);

    bool mockIsOpenEnabled() const;
    bool mockIsLegacy() const;
    bool mockIsBootloader() const;
    MockCommand mockGetCommand() const;
    MockResponse mockGetResponse() const;
    MockVersion mockGetVersion() const;

    bool mockSetOpenEnabled(bool enabled);
    bool mockSetLegacy(bool legacy);
    bool mockSetCommand(MockCommand command);
    bool mockSetResponse(MockResponse response);
    bool mockSetResponseForCommand(MockResponse response, MockCommand command);
    bool mockSetVersion(MockVersion version);
    bool mockSetAsBootloader(bool isBootloader);
    void mockCreateMockFirmware();

private:
    const std::vector<QByteArray> replacePlaceholders(const std::vector<QByteArray> &responses,
                                                       const rapidjson::Document &requestDoc);
    QString getPlaceholderValue(const QString placeholder,
                                       const rapidjson::Document &requestDoc);

    void createMockFirmware();
    void getExpectedValues(QString firmwarePath);

private:
    bool isOpenEnabled_ = true;
    bool isLegacy_ = false;     // very old board without 'get_firmware_info' command support
    bool isBootloader_ = false;
    MockCommand command_ = MockCommand::Any_command;
    MockResponse response_ = MockResponse::Normal;
    MockVersion version_ = MockVersion::Version_1;

    //variables used to store mock firmware's expected values
    int payloadCount_ = 0;
    bool startBackup_ = false;
    QTemporaryFile mockFirmware_;
    int actualChunk_ = -1;
    int expectedChunksCount_ = 0;
    QVector<quint64> expectedChunkSize_;
    QVector<QByteArray> expectedChunkData_;
    QVector<quint16> expectedChunkCrc_;
};

} // namespace strata::device
