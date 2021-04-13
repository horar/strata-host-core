#include "HostControllerServiceNode.h"

#include <QCoreApplication>


HostControllerServiceNode::HostControllerServiceNode(QObject *parent)
    : HostControllerServiceSource(parent)
{
}

HostControllerServiceNode::~HostControllerServiceNode()
{
}

void HostControllerServiceNode::start(const QUrl &hostUrl)
{
    qCDebug(logCategoryHcsNode) << "activating" << hostUrl.toString() << "source node";

    srcNode_.setHostUrl(hostUrl);
    srcNode_.enableRemoting(this);
}

void HostControllerServiceNode::stop()
{
    qCDebug(logCategoryHcsNode) << "deactivating" << srcNode_.hostUrl().toString() << "source node";

    srcNode_.disableRemoting(this);
}

AppInfoPod HostControllerServiceNode::appInfoPod() const
{
    return AppInfoPod(QCoreApplication::applicationName(), QCoreApplication::applicationVersion());
}

void HostControllerServiceNode::shutdown_cb()
{
    qCDebug(logCategoryHcsNode) << "shutting down on remote requested";

    QCoreApplication::exit(0);
}
