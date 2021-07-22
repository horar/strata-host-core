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

    /**
     * Signal emitted on timeout.
     * @param [in] requestId request id.
     */
    void requestTimedout(const int &requestId);

private slots:
    /**
     * Handles timeout signal from QTimer
     */
    void requestTimeoutHandler();

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

    /**
     * Starts timer for timeout.
     */
    void startTimer();

    /**
     * Stops timer for timeout.
     */
    void stopTimer();

    int id_;
    QTimer timer_;
    static constexpr std::chrono::milliseconds REQUEST_TIMEOUT{500};
};
}  // namespace strata::strataRPC
