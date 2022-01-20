/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
