#include "logging/LoggingQtCategories.h"

#include "CoreUpdate.h"

#include <QProcess>
#include <QCoreApplication>

/*
    No-op if not on Windows
*/
#if !defined(Q_OS_WIN)
void CoreUpdate::requestUpdateApplication() {
    qCCritical(logCategoryCoreUpdate) << "CoreUpdate functionality is available only on Windows OS";
}
#else
void CoreUpdate::requestUpdateApplication() {
    // Search for Strata Maintenance Tool in application directory, if found perform update
    const QDir applicationDir(QCoreApplication::applicationDirPath());
    const QString absPathMaintenanceTool = locateMaintenanceTool(applicationDir);
    if (!absPathMaintenanceTool.isEmpty()) {
        performCoreUpdate(absPathMaintenanceTool, applicationDir);
    }
}
#endif

QString CoreUpdate::locateMaintenanceTool(const QDir &applicationDir) {
    const QString maintenanceToolFilename = "Strata Maintenance Tool.exe";
    const QString absPathMaintenanceTool = applicationDir.filePath(maintenanceToolFilename);

    if (!applicationDir.exists(maintenanceToolFilename)) {
        qCCritical(logCategoryCoreUpdate) << maintenanceToolFilename << "not found in" << applicationDir.absolutePath();
        return QString();
    }

    return absPathMaintenanceTool;
}

void CoreUpdate::performCoreUpdate(const QString &absPathMaintenanceTool, const QDir &applicationDir) {
    // Launch Strata Maintenance Tool wizard and quit Strata
    qCCritical(logCategoryCoreUpdate) << "Launching Strata Maintenance Tool";
    QStringList arguments;
    arguments << "isSilent=true" << "forceUpdate=true" << "delayStart=3000";

    QProcess maintenanceToolProcess;
    maintenanceToolProcess.setProgram(absPathMaintenanceTool);
    maintenanceToolProcess.setArguments(arguments);
    maintenanceToolProcess.setWorkingDirectory(applicationDir.absolutePath());
    maintenanceToolProcess.startDetached();

    qCCritical(logCategoryCoreUpdate) << "Quitting Strata Developer Studio";
    QCoreApplication::quit();
}