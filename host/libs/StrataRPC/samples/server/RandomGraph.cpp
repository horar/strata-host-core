#include "RandomGraph.h"

#include <QJsonArray>
#include <QList>
#include <QRandomGenerator>

RandomGraph::RandomGraph(std::shared_ptr<strata::strataRPC::StrataServer> strataServer,
                         QObject *parent)
    : QObject(parent), strataServer_(strataServer)
{
    strataServer_->registerHandler(
        "generate_graph", std::bind(&RandomGraph::generateGraph, this, std::placeholders::_1));
}

RandomGraph::~RandomGraph()
{
}

void RandomGraph::generateGraph(const strata::strataRPC::Message &message)
{
    if (false == message.payload.contains("size")) {
        strataServer_->notifyClient(
            message, QJsonObject{{"status", "Failed"}, {"message", "Invalid command."}},
            strata::strataRPC::ResponseType::Error);
        return;
    }

    strataServer_->notifyClient(message, QJsonObject{{"status", "processing"}},
                                strata::strataRPC::ResponseType::Response);

    QJsonArray randomList;

    for (int i = 0; i < message.payload.value("size").toDouble(); i++) {
        randomList.append(QRandomGenerator::global()->bounded(1, 10));
    }

    strataServer_->notifyClient(message, QJsonObject{{"status", "done"}, {"list", randomList}},
                                strata::strataRPC::ResponseType::Notification);
}
