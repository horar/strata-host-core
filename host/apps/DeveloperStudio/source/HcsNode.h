#pragma once

#include <QObject>
#include <QSharedPointer>

#include "rep_HostControllerService_replica.h"

class HcsNode : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(HcsNode)

public:
    explicit HcsNode(QObject* parent = nullptr);
    ~HcsNode();

public slots:
    void hcsAppInfo(AppInfoPod appInfoPod);
    void connectionChanged(QRemoteObjectReplica::State state, QRemoteObjectReplica::State oldState);

    void shutdownService();

protected:
private:
    void initConnections();

    QRemoteObjectNode replicaNode_;
    QSharedPointer<HostControllerServiceReplica> replica_;
};
