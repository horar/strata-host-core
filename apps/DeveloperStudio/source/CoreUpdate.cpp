#include "logging/LoggingQtCategories.h"

#include "CoreUpdate.h"

#include <QProcess>
#include <QCoreApplication>

QString CoreUpdate::requestUpdateApplication() {
    // Search for Strata Maintenance Tool in application directory, if found perform update
#ifdef Q_OS_MACOS
    const QDir applicationDir(QDir::cleanPath(QString("%1/../../..").arg(QCoreApplication::applicationDirPath())));
#else
    const QDir applicationDir(QCoreApplication::applicationDirPath());
#endif
    QString absPathMaintenanceTool;
    QString error = locateMaintenanceTool(applicationDir, absPathMaintenanceTool);

    if (error.isEmpty()) {
        performCoreUpdate(absPathMaintenanceTool, applicationDir);
        return QString();
    }

    return error;
}

// TODO: this function is duplicated in SDS/HCS, should be unified in future
QString CoreUpdate::locateMaintenanceTool(const QDir &applicationDir, QString &absPathMaintenanceTool) {
#if defined(Q_OS_WIN)
    const QString maintenanceToolFilename = "Strata Maintenance Tool.exe";
#elif defined(Q_OS_MACOS)
    const QString maintenanceToolFilename = "Strata Maintenance Tool.app/Contents/MacOS/Strata Maintenance Tool";
#elif defined(Q_OS_LINUX)
    const QString maintenanceToolFilename = "Strata Maintenance Tool";
#endif
    absPathMaintenanceTool = applicationDir.filePath(maintenanceToolFilename);

    if (applicationDir.exists(maintenanceToolFilename) == false) {
        qCCritical(lcCoreUpdate) << maintenanceToolFilename << "not found in" << applicationDir.absolutePath();
        return QString("Strata Maintenance Tool not found.");
    }

    return QString();
}

void CoreUpdate::performCoreUpdate(const QString &absPathMaintenanceTool, const QDir &applicationDir) {
    // Launch Strata Maintenance Tool wizard and quit Strata
    qCDebug(lcCoreUpdate) << "Launching Strata Maintenance Tool";
    QStringList arguments;
    arguments << "isSilent=true" << "--updater";

    QProcess maintenanceToolProcess;
    maintenanceToolProcess.setProgram(absPathMaintenanceTool);
    maintenanceToolProcess.setArguments(arguments);
    maintenanceToolProcess.setWorkingDirectory(applicationDir.absolutePath());
    maintenanceToolProcess.startDetached();

    qCInfo(lcCoreUpdate) << "Quitting Strata Developer Studio";
    emit applicationTerminationRequested();
    QCoreApplication::quit();
}
