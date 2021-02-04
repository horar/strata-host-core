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
    DeferredRequest(double id, QObject *parent = nullptr);
    ~DeferredRequest();

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
