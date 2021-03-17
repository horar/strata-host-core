#pragma once

#include <StrataRPC/StrataClient.h>
#include <QObject>

class Client : public QObject
{
    Q_OBJECT;
    Q_DISABLE_COPY(Client);
    Q_PROPERTY(bool connectionStatus READ getConnectionStatus NOTIFY connectionStatusUpdated);
    Q_PROPERTY(QString serverTime READ getServerTime NOTIFY serverTimeUpdated);

public:
    Client(QString clientId, QObject *parent = nullptr);
    ~Client();

    bool init();
    void start();

    bool getConnectionStatus();
    QString getServerTime();

signals:
    void connectionStatusUpdated();
    void serverTimeUpdated();
    void randomGraphUpdated(QList<int> randomNumbersList);

public slots:
    void connectToServer();
    void disconnectServer();
    void closeServer();
    void requestRandomGraph();
    void requestServerStatus();
    void serverDisconnectedHandler(const QJsonObject &);
    void strataClientErrorHandler(strata::strataRPC::StrataClient::ClientError errorType,
                                  const QString &errorMessage);
    void serverTimeHandler(const QJsonObject &payload);
    void randomGraphHandler(const QJsonObject &payload);

private:
    std::unique_ptr<strata::strataRPC::StrataClient> strataClient_;
    static constexpr char address_[] = "tcp://127.0.0.1:5564";
    bool connectionStatus_;
    QString serverTime_;
};
