/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QJsonObject>
#include <QString>

#include <functional>

namespace strata::strataRPC
{
enum class ResponseType { Response, Notification, PlatformMessage, Error };

struct Message {
    enum class MessageType { Notification, Command, Response, Error };

    QString handlerName;
    QJsonObject payload;
    int messageID;
    QByteArray clientID;
    MessageType messageType;
};


}  // namespace strata::strataRPC
