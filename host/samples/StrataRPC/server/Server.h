#pragma once

#include <StrataRPC/StrataServer.h>
#include <QObject>

class Server : public QObject
{
    Q_OBJECT;
    Q_DISABLE_COPY(Server);

public:
    explicit Server(QObject *parent = nullptr);
    ~Server();
    bool init();
    void start();

signals:
    void appDone(int exitStatus);

public slots:
    void serverErrorHandler(strata::strataRPC::StrataServer::ServerError errorType,
                            const QString &errorMessage);

private:
    std::unique_ptr<strata::strataRPC::StrataServer> strataServer_;
    static constexpr char address_[] = "tcp://127.0.0.1:5564";
};