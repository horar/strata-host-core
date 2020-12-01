#pragma once

#include <QObject>
#include <QHash>

#include "Request.h"

namespace strata::strataComm {

class RequestsController : public QObject {
    Q_OBJECT

public:
    RequestsController();
    ~RequestsController();
    void addNewRequest(const QString &method, const QJsonObject &payload);
    bool isPendingRequest(int id);
    bool removePendingRequest(int id);

signals:
    void sendRequest(const QByteArray &request);

private:
    QHash<int, strata::strataComm::Request> requestsList_;
    int currentRequestId_;
};

} // namespace strata::strataComm
