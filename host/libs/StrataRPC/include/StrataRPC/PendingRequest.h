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

    // these should go private
    bool callSuccessCallback(const Message &message);
    bool callErrorCallback(const Message &message);

signals:
    void finishedSuccessfully(const Message &message);
    void finishedWithError(const Message &message);

private:
    double id_;
};

}  // namespace strata::strataRPC
