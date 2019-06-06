#include "ProgramDeviceTask.h"

ProgramDeviceTask::ProgramDeviceTask(spyglass::PlatformConnectionShPtr connection, const QString &firmwarePath)
    : connection_(connection), firmwarePath_(firmwarePath)
{
}

void ProgramDeviceTask::run()
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
