#pragma once

#include <StrataRPC/Message.h>
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
    DeferredRequest(int id, QObject *parent = nullptr);

    /**
     * DeferredRequest Destructor
     */
    ~DeferredRequest();

    /**
     * Accessor to the request ID
     * @return request ID
     */
    int getId() const;

    /**
     * Check if the request has a connected slot/lambda to finishedSuccessfully signal.
     * @return boolean if a signal/slot is connected to finishedSuccessfully signal.
     */
    bool hasSuccessCallback();

    /**
     * Check if the request has a connected slot/lambda to finishedWithError signal.
     * @return boolean if a signal/slot is connected to finishedWithError signal.
     */
    bool hasErrorCallback();

signals:
    /**
     * Signal Emitted when the server respond with a successful message.
     * @param [in] message parsed server message.
     */
    void finishedSuccessfully(const Message &message);

    /**
     * Signal Emitted when the server respond with a Error message.
     * @param [in] message parsed server message.
     */
    void finishedWithError(const Message &message);

    /**
     * Signal emitted on timeout
     * @param [in] requestId request id.
     */
    void requestTimedOut(int requestId);

private:
    friend class StrataClient;

    /**
     * Emits finishedSuccessfully signal.
     * @param [in] message parsed server message.
     */
    void callSuccessCallback(const Message &message);

    /**
     * Emits finishedWithError signal.
     * @param [in] message parsed server message.
     */
    void callErrorCallback(const Message &message);

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
};
}  // namespace strata::strataRPC
