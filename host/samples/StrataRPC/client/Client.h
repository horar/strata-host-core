#pragma once

#include <QObject>
#include <StrataRPC/StrataClient.h>

class Client : public QObject
{
    Q_OBJECT;
    Q_DISABLE_COPY(Client);

public:
    Client(QObject *parent = nullptr);
    ~Client();
    
    bool init();
    void start();

private:
    std::unique_ptr<strata::strataRPC::StrataClient> strataClient_;
    static constexpr char address_[] = "tcp://127.0.0.1:5564";
};
