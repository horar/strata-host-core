#pragma once

#include <QObject>
#include <QNetworkReply>
#include <QBasicTimer>

/**
 * Timed timeout trigger since QNetworkReply does not inherently timeout
 * There is transfer timeout property since Qt 5.15, which effectively replaces our ReplyTimeout
 */

namespace strata {

class ReplyTimeout : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(ReplyTimeout)

public:
    ReplyTimeout(QNetworkReply* reply, const int timeout) : QObject(reply) {
        Q_ASSERT(reply);
        milliseconds_ = timeout;
        if (reply && reply->isRunning())
             mSec_timer_.start(timeout, this);
    }
    static void set(QNetworkReply* reply, const int timeout) {
        new ReplyTimeout(reply, timeout);
    }

private:
    int milliseconds_;
    QBasicTimer mSec_timer_;

    void timerEvent(QTimerEvent * ev);
};

}
