/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include "rep_HostControllerService_source.h"

#include "logging/LoggingQtCategories.h"


class HostControllerServiceNode final : public HostControllerServiceSource
{
    Q_OBJECT
    Q_DISABLE_COPY(HostControllerServiceNode)

public:
    explicit HostControllerServiceNode(unsigned hcsIdentifier, QObject* parent = nullptr);
    ~HostControllerServiceNode();

    void start(const QUrl& hostUrl);
    void stop();

    // HostControllerServiceSource interface
    virtual AppInfoPod appInfoPod() const override;

public slots:
    // HostControllerServiceSource interface
    virtual void shutdown_cb(unsigned hcsIdentifier) override;

protected:
private:
    QRemoteObjectHost srcNode_;
    const unsigned hcsIdentifier_;
};
