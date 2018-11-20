#include <iostream>
#include <string>
#include <pthread.h>
#include <stdlib.h>
#include <list>
#include <algorithm>
#include <memory>
#include <QJsonObject>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonValue>
#include <QJsonArray>
#include <QJsonObject>
#include "zhelpers.hpp"
#include "zmq.hpp"
#include "zmq_addon.hpp"


#ifndef HOSTCONTROLLERCLIENT_H
#define HOSTCONTROLLERCLIENT_H

class HostControllerClient {

public:
    HostControllerClient();
    ~HostControllerClient();
    bool sendCmd(QJsonObject cmd);
    QJsonObject receiveCommandAck();
    QJsonObject receiveNotification();

private:
    zmq::context_t *context;
    zmq::socket_t *sendCmdSocket;
    zmq::socket_t *notificationSocket;
};

#endif // HOSTCONTROLLERCLIENT_H
