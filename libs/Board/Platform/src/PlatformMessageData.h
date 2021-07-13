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

    const QByteArray raw_;
    rapidjson::Document json_;
    QString jsonErrorString_;
    ulong jsonErrorOffset_;
};

}  // namespace
