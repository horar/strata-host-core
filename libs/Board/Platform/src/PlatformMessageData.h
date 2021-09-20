/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
