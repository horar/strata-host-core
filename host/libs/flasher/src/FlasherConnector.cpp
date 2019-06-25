#include "FlasherConnector.h"

#include <QThreadPool>

FlasherTask::FlasherTask(spyglass::PlatformConnectionShPtr connection, const QString &firmwarePath)
    : connection_(connection), firmwarePath_(firmwarePath)
{
}

void FlasherTask::run()
{
    Q_ASSERT(connection_ != nullptr);
    if (connection_ == nullptr) {
        return;
    }

    Flasher flasher(connection_, firmwarePath_.toStdString());

    QString connectionId = QString::fromStdString(connection_->getName());

    emit notify(connectionId, "Initializing bootloader");

    if (flasher.initializeBootloader()) {
        emit notify(connectionId, "Programming");
        if (flasher.flash(true)) {

            emit taskDone(connectionId, true);
            return;
        }
    } else {
        emit notify(connectionId, "Initializing of bootloader failed");
    }

    emit taskDone(connectionId, false);
}

FlasherConnector::FlasherConnector(QObject *parent)
    : QObject(parent)
{
}

void FlasherConnector::start(spyglass::PlatformConnectionShPtr connection, const QString &firmwarePath)
{
    FlasherTask *task = new FlasherTask(connection, firmwarePath);

    connect(task, &FlasherTask::taskDone,
            this, &FlasherConnector::taskDone);

    connect(task, &FlasherTask::notify,
            this, &FlasherConnector::notify);

    QThreadPool::globalInstance()->start(task);
}
