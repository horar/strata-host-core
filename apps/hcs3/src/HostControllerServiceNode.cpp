#include "HostControllerServiceNode.h"

#include <QCoreApplication>


HostControllerServiceNode::HostControllerServiceNode(unsigned hcsIdentifier, QObject *parent)
    : HostControllerServiceSource(parent), hcsIdentifier_(hcsIdentifier)
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

void HostControllerServiceNode::shutdown_cb(unsigned hcsIdentifier)
{
    if (hcsIdentifier_ == hcsIdentifier) {
        qCDebug(logCategoryHcsNode) << "shutting down on remote requested";
        QCoreApplication::exit(0);
    } else {
        qCDebug(logCategoryHcsNode) << "HCS Identifier not matching, shutdown request ignored, our:" << hcsIdentifier_ << "requested:" << hcsIdentifier;
    }
}
