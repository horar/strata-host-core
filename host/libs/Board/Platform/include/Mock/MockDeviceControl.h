#pragma once

#include <Mock/MockDeviceConstants.h>
#include <rapidjson/document.h>
#include <QString>

namespace strata::device {

class MockDeviceControl : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(MockDeviceControl)

public:
    explicit MockDeviceControl(QObject *parent = nullptr);
    ~MockDeviceControl() override;

    std::vector<QByteArray> getResponses(QByteArray request);

    bool mockIsBootloader() const;
    bool mockIsLegacy() const;
    MockCommand mockGetCommand() const;
    MockResponse mockGetResponse() const;

    bool mockSetLegacy(bool legacy);
    bool mockSetCommand(MockCommand command);
    bool mockSetResponse(MockResponse response);
    bool mockSetResponseForCommand(MockResponse response, MockCommand command);
    bool mockSetVersion(MockVersion version);

private:
    static std::vector<QByteArray> replacePlaceholders(const std::vector<QByteArray> &responses,
                                                       const rapidjson::Document &requestDoc);
    static QString getPlaceholderValue(const QString placeholder,
                                       const rapidjson::Document &requestDoc);
private:
    bool isLegacy_ = false;     // very old board without 'get_firmware_info' command support
    bool isBootloader_ = false;
    MockCommand command_ = MockCommand::all_commands;
    MockResponse response_ = MockResponse::normal;
    MockVersion version_ = MockVersion::version1;
};

} // namespace strata::device
