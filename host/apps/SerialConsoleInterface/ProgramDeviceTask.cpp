#include "ProgramDeviceTask.h"

#include <QDebug>

ProgramDeviceTask::ProgramDeviceTask(spyglass::PlatformConnection *connection, const QString &firmwarePath)
    : connection_(connection), firmwarePath_(firmwarePath)
{
}

void ProgramDeviceTask::run()
{
    if (connection_ == nullptr) {
        emit taskDone(connection_, false);
        return;
    }

    Flasher flasher(connection_, firmwarePath_.toStdString());

    emit notify(QString::fromStdString(connection_->getName()), "Initializing bootloader");

    if (flasher.initializeBootloader()) {
        emit notify(QString::fromStdString(connection_->getName()), "Programming");
        if (flasher.flash(true)) {
            emit taskDone(connection_, true);
            return;
        }
    } else {
        emit notify(QString::fromStdString(connection_->getName()), "Initializing of bootloader failed");
    }

    emit taskDone(connection_, false);
}
