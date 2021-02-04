#pragma once

#include <StrataRPC/Message.h>
#include <QObject>

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
    DeferredRequest(double id, QObject *parent = nullptr);

    /**
     * DeferredRequest Destructor
     */
    ~DeferredRequest();

    /**
     * Accessor to the request ID
     * @return request ID
     */
    double getId() const;

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
     */
    void finishedSuccessfully(const Message &message);

    /**
     * Signal Emitted when the server respond with a Error message.
     */
    void finishedWithError(const Message &message);

private:
    friend class StrataClient;

    /**
     * Emits finishedSuccessfully signal.
     */
    void callSuccessCallback(const Message &message);

    /**
     * Emits finishedWithError signal.
     */
    void callErrorCallback(const Message &message);

    double id_;
};
}  // namespace strata::strataRPC
