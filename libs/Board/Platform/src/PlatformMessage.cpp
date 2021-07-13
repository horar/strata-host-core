#include <PlatformMessage.h>
#include <PlatformMessageData.h>

namespace strata::platform {

PlatformMessage::PlatformMessage()
    : data_(new PlatformMessageData())
{ }

PlatformMessage::PlatformMessage(const QByteArray& rawMessage)
    : data_(new PlatformMessageData(rawMessage))
{ }

PlatformMessage::PlatformMessage(const PlatformMessage& other)
    : data_(other.data_)
{ }

PlatformMessage::~PlatformMessage()
{ }

const QByteArray& PlatformMessage::raw() const
{
    return data_->raw_;
}

const rapidjson::Document& PlatformMessage::json() const
{
    return data_->json_;
}

bool PlatformMessage::isJsonValid() const
{
    return (data_->json_.IsNull() == false);
}

bool PlatformMessage::isJsonValidObject() const
{
    return (isJsonValid() && data_->json_.IsObject());
}

const QString& PlatformMessage::jsonErrorString() const
{
    return data_->jsonErrorString_;
}

ulong PlatformMessage::jsonErrorOffset() const
{
    return data_->jsonErrorOffset_;
}

}  // namespace
