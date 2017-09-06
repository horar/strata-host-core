#include <iostream>
#include <string>
#include <pthread.h>
#include <stdlib.h>
#include <list>
#include <algorithm>
#include <syslog.h>
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


#define DEBUG
#ifdef DEBUG
#define DBGLEVEL LOG_DEBUG
#define SYSLOGLEVEL LOG_WARNING
#define dbgprint(level, ...) {\
    if(level >= SYSLOGLEVEL) syslog(LOG_WARNING, __VA_ARGS__);\
    if(level >= DBGLEVEL) printf(__VA_ARGS__); putchar('\n');\
}

#else // DEBUG
#define dbgprint(...)
#endif // DEBUG

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
