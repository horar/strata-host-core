#include <PlatformMessageData.h>

#include <rapidjson/error/en.h>

#include "logging/LoggingQtCategories.h"

namespace strata::platform {

PlatformMessageData::PlatformMessageData()
    : jsonErrorString(QStringLiteral("Message was not provided.")),
      jsonErrorOffset(0)
{ }

PlatformMessageData::PlatformMessageData(const QByteArray& rawMessage)
    : raw(rawMessage),
      jsonErrorOffset(0)
{
    rapidjson::ParseResult result = json.Parse(rawMessage.data(), rawMessage.size());

    if (result.IsError()) {
        jsonErrorString = rapidjson::GetParseError_En(result.Code());
        jsonErrorOffset = static_cast<uint>(result.Offset());

        qCWarning(logCategoryPlatformMessage).nospace().noquote()
            << QStringLiteral("JSON parse error at offset ") << jsonErrorOffset
            << QStringLiteral(": ") << jsonErrorString
            << QStringLiteral(" Invalid JSON: '") << rawMessage << '\'';
    }
}

PlatformMessageData::PlatformMessageData(const PlatformMessageData& other)
    : QSharedData(other),
      raw(other.raw),
      jsonErrorString(other.jsonErrorString),
      jsonErrorOffset(other.jsonErrorOffset)
{
    json.CopyFrom(other.json, json.GetAllocator());
}

PlatformMessageData::~PlatformMessageData()
{ }

}  // namespace
