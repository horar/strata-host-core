#include "HostControllerClient.h"
#include <assert.h>

using namespace  std;

HostControllerClient::HostControllerClient() {

    context = new zmq::context_t;
    sendCmdSocket = new zmq::socket_t(*context,ZMQ_DEALER);
    sendCmdSocket->connect("tcp://127.0.0.1:5564");
    sendCmdSocket->setsockopt(ZMQ_IDENTITY,"ONSEMI",sizeof("ONSEMI"));

    notificationSocket = new zmq::socket_t(*context,ZMQ_SUB);
    notificationSocket->connect("tcp://127.0.0.1:5563");
    notificationSocket->setsockopt(ZMQ_SUBSCRIBE,"ONSEMI",strlen("ONSEMI"));

    //Unique Identity generator
    //Will be replaced by random generator sent by HostControllerService in future

#if (defined (WIN32))
    s_set_id(*sendCmdSocket, (intptr_t)args);
#else
    s_set_id(*sendCmdSocket);
#endif
    //request platform-id first step before proceeding with further request
    s_send(*sendCmdSocket,"{\"cmd\":\"request_platform_id\",\"Host_OS\":\"Linux\"}");
    s_recv(*sendCmdSocket);
}

HostControllerClient::~HostControllerClient(){}

bool HostControllerClient::sendCmd(QJsonObject cmd) {

    QJsonDocument doc(cmd);
    QString strJson(doc.toJson(QJsonDocument::Compact));
    std::string command = strJson.toUtf8().constData();
    s_send(*sendCmdSocket,command.c_str());
    qDebug() << "Command Send done = " <<QString::fromStdString(command);
    return true;
}

QJsonObject HostControllerClient::receiveCommandAck() {

    QJsonObject jsonResponse;

    string Ack = s_recv(*sendCmdSocket);

    QString QAck = QString::fromStdString(Ack);
    QJsonDocument doc= QJsonDocument::fromJson(QAck.toUtf8());
    jsonResponse=doc.object();
    //qDebug() << "JSON Command Response Received =  " <<jsonResponse;
    return jsonResponse;
}

QJsonObject HostControllerClient::receiveNotification() {

    QJsonObject jsonResponse;
    s_recv(*notificationSocket);
    std::string message = s_recv(*notificationSocket);

    QString response = QString::fromStdString(message);
    //qDebug() << "Converted QString = " << response;

    QJsonDocument doc= QJsonDocument::fromJson(response.toUtf8());
    jsonResponse=doc.object();
    //qDebug() << "JSON DATA = " << jsonResponse;
    return jsonResponse;
}

