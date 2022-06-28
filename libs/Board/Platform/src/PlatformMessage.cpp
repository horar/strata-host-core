/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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

PlatformMessage& PlatformMessage::operator=(const PlatformMessage& other)
{
    if (this != &other) {
        data_ = other.data_;
    }
    return *this;
}

const QByteArray& PlatformMessage::raw() const
{
    return data_->raw_;
}

const QByteArray PlatformMessage::rawNoNewlineEnd() const
{
    if (data_->raw_.endsWith('\n')) {
        return data_->raw_.chopped(1);
    } else {
        return data_->raw_;
    }
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
