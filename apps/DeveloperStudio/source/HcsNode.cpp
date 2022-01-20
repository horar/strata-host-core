/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "HcsNode.h"

#include "logging/LoggingQtCategories.h"

#include <QCoreApplication>

HcsNode::HcsNode(QObject *parent) : QObject(parent)
{
    initConnections();
}

HcsNode::~HcsNode()
{
}

bool HcsNode::hcsConnected() const
{
    return hcsConnected_;
}

void HcsNode::initConnections()
{
    qCDebug(lcDevStudioNode) << "connecting for source node";
    if (replicaNode_.connectToNode(QUrl(QStringLiteral("local:hcs3"))) == false) {
        qCCritical(lcDevStudioNode)
            << QStringLiteral("connection to source node failed: %1").arg(replicaNode_.lastError());
        return;
    }
    replica_.reset(replicaNode_.acquire<HostControllerServiceReplica>());

    QObject::connect(replica_.data(), &HostControllerServiceReplica::appInfoPodChanged, this,
                     &HcsNode::hcsAppInfo);

    QObject::connect(replica_.data(), &QRemoteObjectReplica::stateChanged, this,
                     &HcsNode::connectionChanged);
}

void HcsNode::hcsAppInfo(AppInfoPod appInfoPod)
{
    qCInfo(lcDevStudioNode) << QStringLiteral("Connected to: %1 %2")
                                                  .arg(appInfoPod.appName())
                                                  .arg(appInfoPod.appVersion());
}

void HcsNode::connectionChanged(QRemoteObjectReplica::State state,
                                QRemoteObjectReplica::State oldState)
{
    qCDebug(lcDevStudioNode) << oldState << "->" << state;

    setHcsConnected(state == QRemoteObjectReplica::Valid);
}

void HcsNode::shutdownService(unsigned hcsIdentifier)
{
    if ((replica_->isReplicaValid() == false) && ((replica_->isInitialized() == true) || (replica_.data()->waitForSource(500) == false))) {
        qCWarning(lcDevStudioNode) << "can't shutdown, not connected to HCS";
        return;
    }

    qCDebug(lcDevStudioNode) << "requesting HCS to shut down";
    replica_->shutdown_cb(hcsIdentifier);
}

void HcsNode::setHcsConnected(bool hcsConnected)
{
    if (hcsConnected_ == hcsConnected) {
        return;
    }

    hcsConnected_ = hcsConnected;
    emit hcsConnectedChanged(hcsConnected_);
}
