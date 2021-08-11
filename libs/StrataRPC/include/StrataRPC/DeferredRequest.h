#pragma once

#include <QObject>
#include <QTimer>

namespace strata::strataRPC
{
class DeferredRequest : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(DeferredRequest);

public:
    /**
     * DeferredRequest constructor
     * @param [in] id request ID
     */
    DeferredRequest(const int &id, QObject *parent = nullptr);

    /**
     * DeferredRequest Destructor
     */
    ~DeferredRequest();

    /**
     * Accessor to the request ID
     * @return request ID
     */
    int getId() const;

signals:
    /**
     * Signal Emitted when the server respond with a successful message.
     * @param [in] jsonPayload QJsonObject of the payload.
     */
    void finishedSuccessfully(const QJsonObject &jsonPayload);

    /**
     * Signal Emitted when the server respond with a Error message.
     * @param [in] jsonPayload QJsonObject of the payload.
     */
    void finishedWithError(const QJsonObject &jsonPayload);

private:
    friend class StrataClient;

    /**
     * Emits finishedSuccessfully signal.
     * @param [in] jsonPayload QJsonObject of the payload.
     */
    void callSuccessCallback(const QJsonObject &jsonPayload);

    /**
     * Emits finishedWithError signal.
     * @param [in] jsonPayload QJsonObject of the payload.
     */
    void callErrorCallback(const QJsonObject &jsonPayload);

    int id_;
};
}  // namespace strata::strataRPC
