/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
