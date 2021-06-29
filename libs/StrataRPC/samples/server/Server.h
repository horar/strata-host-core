#pragma once

#include <StrataRPC/StrataServer.h>
#include <QObject>
#include <QTimer>

#include "RandomGraph.h"

class Server : public QObject
{
    Q_OBJECT;
    Q_DISABLE_COPY(Server);

public:
    explicit Server(QObject *parent = nullptr);
    ~Server();
    void init();
    void start();

signals:
    void appDone(int exitStatus);

public slots:
    void serverErrorHandler(strata::strataRPC::StrataServer::ServerError errorType,
                            const QString &errorMessage);
    void serverTimeBroadcast();

private:
    void closeServerHandler(const strata::strataRPC::Message &message);
    void serverStatusHandler(const strata::strataRPC::Message &message);

    std::shared_ptr<strata::strataRPC::StrataServer> strataServer_;
    static constexpr char address_[] = "tcp://127.0.0.1:5564";
    QTimer serverTimeBroadcastTimer_;
    std::unique_ptr<RandomGraph> randomGraph_;
};