#include "HcsNode.h"

#include "logging/LoggingQtCategories.h"

#include <QCoreApplication>

HcsNode::HcsNode(QObject *parent) : QObject(parent)
{
    replicaNode_.setHeartbeatInterval(10000);

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
    qCDebug(logCategoryStrataDevStudioNode) << "connecting for source node";
    if (replicaNode_.connectToNode(QUrl(QStringLiteral("local:hcs3"))) == false) {
        qCCritical(logCategoryStrataDevStudioNode)
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
    qCInfo(logCategoryStrataDevStudioNode) << QStringLiteral("Connected to: %1 %2")
                                                  .arg(appInfoPod.appName())
                                                  .arg(appInfoPod.appVersion());
}

void HcsNode::connectionChanged(QRemoteObjectReplica::State state,
                                QRemoteObjectReplica::State oldState)
{
    qCDebug(logCategoryStrataDevStudioNode) << oldState << "->" << state;

    setHcsConnected(state == QRemoteObjectReplica::Valid);
}

void HcsNode::shutdownService()
{
    if (replica_->isReplicaValid() == false) {
        qCWarning(logCategoryStrataDevStudioNode) << "can't shutdown, not connected to HCS";
        return;
    }

    qCDebug(logCategoryStrataDevStudioNode) << "requesting HCS to shut down";
    replica_->shutdown_cb();
}

void HcsNode::setHcsConnected(bool hcsConnected)
{
    if (hcsConnected_ == hcsConnected) {
        return;
    }

    hcsConnected_ = hcsConnected;
    emit hcsConnectedChanged(hcsConnected_);
}
