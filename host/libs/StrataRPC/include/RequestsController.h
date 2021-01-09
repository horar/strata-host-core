#pragma once

#include "Request.h"

#include <QHash>
#include <QObject>

namespace strata::strataRPC
{
class RequestsController : public QObject
{
    Q_OBJECT

public:
    /**
     * RequestController constructor
     */
    RequestsController();

    /**
     * RequestController destructor
     */
    ~RequestsController();

    /**
     * Adds a new request.
     * @param [in] method request handler name.
     * @param [in] payload QJsonObject of the request payload.
     * @return QByteArray of json formatted request.
     */
    [[nodiscard]] QByteArray addNewRequest(const QString &method, const QJsonObject &payload);

    /**
     * Checks if there is a pending request with a specific id
     * @param [in] id pending request id.
     * @return True if there is a pending request with the same id.
     */
    bool isPendingRequest(int id);

    /**
     * Removes a pending id
     * @param [in] id pending request id.
     * @return True if the pending request was removed successfully, False if there is no pending
     * requests with the same id
     */
    bool removePendingRequest(int id);

    /**
     * return the handlerName of a pending request using it's id
     * @param [in] id pending request id.
     * @return QString of the handler name. This will return an empty string if there is no pending
     * request with the same id.
     */
    [[nodiscard]] QString getMethodName(int id);

private:
    QHash<int, strata::strataRPC::Request> requestsList_;
    int currentRequestId_;
};

}  // namespace strata::strataRPC
