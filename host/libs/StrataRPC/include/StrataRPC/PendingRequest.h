#pragma once

#include <StrataRPC/Message.h>
#include <QObject>

namespace strata::strataRPC
{
class PendingRequest : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(PendingRequest);

public:
    PendingRequest(double id, QObject *parent = nullptr);
    ~PendingRequest();

    double getId() const;
    bool hasSuccessCallback();
    bool hasErrorCallback();

signals:
    void finishedSuccessfully(const Message &message);
    void finishedWithError(const Message &message);

private:
    friend class StrataClient;
    void callSuccessCallback(const Message &message);
    void callErrorCallback(const Message &message);
    double id_;
};

}  // namespace strata::strataRPC
