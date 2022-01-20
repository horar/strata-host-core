/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "ReplyTimeout.h"
#include "logging/LoggingQtCategories.h"

#include <QTimerEvent>

namespace strata {

void ReplyTimeout::timerEvent(QTimerEvent *ev)
{
    if (mSec_timer_.isActive() == false
            || ev->timerId() != mSec_timer_.timerId()) {
        return;
    }

    QNetworkReply* reply = qobject_cast<QNetworkReply*>(QObject::parent());

    if (reply->isRunning()){
        if (reply->property("newProgress").toBool()) {
            qCDebug(lcDownloadManager) << "Restarting timeout timer for:" << reply->url();
            mSec_timer_.start(this->milliseconds_, this);
            reply->setProperty("newProgress", false);
            return;
        } else {
            qCDebug(lcDownloadManager) << "Time is up. Manually closing:" << reply->url();
            reply->close();
        }
    }
    mSec_timer_.stop();
}

}
