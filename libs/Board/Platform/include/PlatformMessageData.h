#pragma once

#include <QSharedData>
#include <QByteArray>
#include <QString>

#include <rapidjson/document.h>

namespace strata::platform {

class PlatformMessageData : public QSharedData
{
public:
    PlatformMessageData();
    PlatformMessageData(const QByteArray& rawMessage);
    PlatformMessageData(const PlatformMessageData& other);
    ~PlatformMessageData();

    const QByteArray raw;
    rapidjson::Document json;
    QString jsonErrorString;
    uint jsonErrorOffset;
};

}  // namespace
