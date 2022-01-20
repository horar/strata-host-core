/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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

    bool getConnectionStatus() const;
    QString getServerTime() const;

signals:
    void connectionStatusUpdated();
    void serverTimeUpdated();
    void randomGraphUpdated(QList<int> randomNumbersList);
    void serverDelayUpdated(qint64 delay);
    void errorOccurred(const QString &errorMessage);

public slots:
    void connectToServer();
    void disconnectServer();
    void closeServer();
    void requestRandomGraph();
    void requestServerStatus();
    void pingServer();

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
