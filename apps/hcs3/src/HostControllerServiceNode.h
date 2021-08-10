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
