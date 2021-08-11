#pragma once

#include <QObject>
#include <QSharedPointer>

#include "rep_HostControllerService_replica.h"

class HcsNode : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(HcsNode)
    Q_PROPERTY(bool hcsConnected READ hcsConnected NOTIFY hcsConnectedChanged)

public:
    explicit HcsNode(QObject* parent = nullptr);
    ~HcsNode();

    bool hcsConnected() const;

public slots:
    void hcsAppInfo(AppInfoPod appInfoPod);
    void connectionChanged(QRemoteObjectReplica::State state, QRemoteObjectReplica::State oldState);

    void shutdownService(unsigned hcsIdentifier);


signals:
    void hcsConnectedChanged(bool hcsConnected);

protected:
private:
    void initConnections();
    void setHcsConnected(bool hcsConnected);

    QRemoteObjectNode replicaNode_;
    QSharedPointer<HostControllerServiceReplica> replica_;

    bool hcsConnected_{false};
};
