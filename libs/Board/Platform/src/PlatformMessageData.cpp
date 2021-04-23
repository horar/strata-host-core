#include <PlatformMessageData.h>

#include <rapidjson/error/en.h>

#include "logging/LoggingQtCategories.h"

namespace strata::platform {

PlatformMessageData::PlatformMessageData()
    : jsonErrorString_(QStringLiteral("Message was not provided.")),
      jsonErrorOffset_(0)
{ }

PlatformMessageData::PlatformMessageData(const QByteArray& rawMessage)
    : raw_(rawMessage),
      jsonErrorOffset_(0)
{
    rapidjson::ParseResult result = json_.Parse(raw_.data(), raw_.size());

    if (result.IsError()) {
        jsonErrorString_ = rapidjson::GetParseError_En(result.Code());
        jsonErrorOffset_ = static_cast<uint>(result.Offset());

        qCWarning(logCategoryPlatformMessage).nospace().noquote()
            << QStringLiteral("JSON parse error at offset ") << jsonErrorOffset_
            << QStringLiteral(": ") << jsonErrorString_
            << QStringLiteral(" Invalid JSON: '") << raw_ << '\'';
    }
}

PlatformMessageData::PlatformMessageData(const PlatformMessageData& other)
    : QSharedData(other),
      raw_(other.raw_),
      jsonErrorString_(other.jsonErrorString_),
      jsonErrorOffset_(other.jsonErrorOffset_)
{
    json_.CopyFrom(other.json_, json_.GetAllocator());
}

PlatformMessageData::~PlatformMessageData()
{ }

}  // namespace
