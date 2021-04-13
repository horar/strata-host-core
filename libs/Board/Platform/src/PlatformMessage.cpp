#include <PlatformMessage.h>
#include <PlatformMessageData.h>

namespace strata::platform {

PlatformMessage::PlatformMessage()
    : data(new PlatformMessageData())
{ }

PlatformMessage::PlatformMessage(const QByteArray& rawMessage)
    : data(new PlatformMessageData(rawMessage))
{ }

PlatformMessage::PlatformMessage(const PlatformMessage& other)
    : data(other.data)
{ }

PlatformMessage::~PlatformMessage()
{ }

const QByteArray& PlatformMessage::raw() const
{
    return data->raw;
}

const rapidjson::Document& PlatformMessage::json() const
{
    return data->json;
}

bool PlatformMessage::isJsonValid() const
{
    return (data->json.IsNull() == false);
}

const QString& PlatformMessage::jsonErrorString() const
{
    return data->jsonErrorString;
}

uint PlatformMessage::jsonErrorOffset() const
{
    return data->jsonErrorOffset;
}

}  // namespace
