#pragma once

#include <QObject>
#include <QSharedData>
#include <QByteArray>
#include <QString>

#include <rapidjson/document.h>

namespace strata::platform {

class PlatformMessageData;

class PlatformMessage
{
public:
    PlatformMessage();
    PlatformMessage(const QByteArray& rawMessage);
    PlatformMessage(const PlatformMessage& other);
    ~PlatformMessage();

    const QByteArray& raw() const;
    const rapidjson::Document& json() const;

    bool isJsonValid() const;
    const QString& jsonErrorString() const;
    uint jsonErrorOffset() const;

private:
    QSharedDataPointer<PlatformMessageData> data;
};

}  // namespace

Q_DECLARE_METATYPE(strata::platform::PlatformMessage);
