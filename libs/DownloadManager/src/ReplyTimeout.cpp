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
            qCDebug(logCategoryDownloadManager) << "Restarting timeout timer for:" << reply->url();
            mSec_timer_.start(this->milliseconds_, this);
            reply->setProperty("newProgress", false);
            return;
        } else {
            qCDebug(logCategoryDownloadManager) << "Time is up. Manually closing:" << reply->url();
            reply->close();
        }
    }
    mSec_timer_.stop();
}

}
