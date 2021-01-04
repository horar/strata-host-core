#pragma once

#include <QHash>
#include <QObject>

#include "Request.h"

namespace strata::strataComm
{
class RequestsController : public QObject
{
    Q_OBJECT

public:
    RequestsController();
    ~RequestsController();
    QByteArray addNewRequest(const QString &method, const QJsonObject &payload);
    bool isPendingRequest(int id);
    bool removePendingRequest(int id);
    QString getMethodName(int id);

signals:
    void sendRequest(const QByteArray &request);

private:
    QHash<int, strata::strataComm::Request> requestsList_;
    int currentRequestId_;
};

}  // namespace strata::strataComm
