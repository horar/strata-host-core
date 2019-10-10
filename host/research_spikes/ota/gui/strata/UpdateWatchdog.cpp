#include "UpdateWatchdog.h"

#include <QDebug>

UpdateWatchdog::UpdateWatchdog(QObject *parent) : QObject(parent)
{
    connect(&process_, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            [=](int exitCode, QProcess::ExitStatus exitStatus) {
        qDebug() << "F:" << exitCode << " - " << exitStatus;

        QString msg;
        if (exitCode == 0) {
            msg = process_.readAllStandardOutput();
        }
        // TODO: updates XML or text about 'no updates...'
        setOutput(msg);

        // setOutput(process_.readAllStandardError());
            });
    connect(&process_, &QProcess::errorOccurred,
            [=](QProcess::ProcessError error){ qDebug() << "E:" << error; });
}

void UpdateWatchdog::checkForUpdate()
{
    if (process_.state() != QProcess::NotRunning) {
        qWarning() << "E: can't start process -" << process_.state();
        return;
    }

    //    qDebug() << Q_FUNC_INFO << "1" << maintenanceAppPath_;
    process_.start(maintenanceAppPath_, {QStringLiteral("--checkupdates")});
    //    qDebug() << Q_FUNC_INFO << "2";
}

void UpdateWatchdog::silentUpdate()
{
    // TODO: may be stop 'stop check for updates' process...

    qDebug() << "silent update ...";
    QProcess updateProcess;
    // TODO: start detached & quit/restart the app if updateing main app
    // TODO: reload/restart UI if updating QRC files with e.g. views/libraries
    updateProcess.start(maintenanceAppPath_, {QStringLiteral("--silentUpdate")});
    updateProcess.waitForFinished();
    qDebug() << updateProcess.error() << "->" << updateProcess.errorString();
    qDebug() << updateProcess.readAllStandardOutput();
    qDebug() << updateProcess.readAllStandardError();
}

void UpdateWatchdog::installComponent()
{
    // TODO: be carefull to not run auto-update & install together (may be a problem?)

    qDebug() << "install component ...";
    QProcess installProcess;
    // TODO: start detached & quit/restart the app if updateing main app
    // TODO: reload/restart UI if updating QRC files with e.g. views/libraries
    // TODO: load new UI for connected platform...
    QStringList args;
    args << QStringLiteral("--script") << QStringLiteral("strata-installer-noninteractive.qs") << QStringLiteral("-v");
    installProcess.start(maintenanceAppPath_, args);
    installProcess.waitForFinished();
    qDebug() << installProcess.error() << "->" << installProcess.errorString();
    qDebug() << installProcess.readAllStandardOutput();
    qDebug() << installProcess.readAllStandardError();
}


QString UpdateWatchdog::output() const
{
    return m_output;
}

void UpdateWatchdog::setOutput(QString output)
{
    if (m_output == output) {
        return;
    }

    m_output = output;
    emit outputChanged(m_output);
}
