#include "RandomGraph.h"

#include <QJsonArray>
#include <QList>
#include <QRandomGenerator>

using namespace strata::strataRPC;

RandomGraph::RandomGraph(std::shared_ptr<StrataServer> strataServer, QObject *parent)
    : QObject(parent), strataServer_(strataServer)
{
    strataServer_->registerHandler(
        "generate_graph", std::bind(&RandomGraph::generateGraph, this, std::placeholders::_1));
}

RandomGraph::~RandomGraph()
{
}

void RandomGraph::generateGraph(const Message &message)
{
    if (false == message.payload.contains("size")) {
        strataServer_->notifyClient(
            message, QJsonObject{{"status", "Failed"}, {"message", "Invalid command."}},
            ResponseType::Error);
        return;
    }

    strataServer_->notifyClient(message, QJsonObject{{"status", "processing"}},
                                ResponseType::Response);

    QJsonArray randomList;

    for (int i = 0; i < message.payload.value("size").toDouble(); i++) {
        randomList.append(QRandomGenerator::global()->bounded(1, 10));
    }

    strataServer_->notifyClient(message, QJsonObject{{"status", "done"}, {"list", randomList}},
                                ResponseType::Notification);
}
