#include "logging/LoggingQtCategories.h"

#include "CoreUpdate.h"

#include <QProcess>
#include <QCoreApplication>

/*
    No-op if not on Windows
*/
#if !defined(Q_OS_WIN)
QString CoreUpdate::requestUpdateApplication() {
    qCCritical(logCategoryCoreUpdate) << "CoreUpdate functionality is available only on Windows OS";
    return QString("CoreUpdate functionality is available only on Windows OS");
}
#else
QString CoreUpdate::requestUpdateApplication() {
    // Search for Strata Maintenance Tool in application directory, if found perform update
    const QDir applicationDir(QCoreApplication::applicationDirPath());
    QString absPathMaintenanceTool;
    QString error = locateMaintenanceTool(applicationDir, absPathMaintenanceTool);

    if (error.isEmpty()) {
        performCoreUpdate(absPathMaintenanceTool, applicationDir);
        return QString();
    }

    return error;
}
#endif

QString CoreUpdate::locateMaintenanceTool(const QDir &applicationDir, QString &absPathMaintenanceTool) {
    const QString maintenanceToolFilename = "Strata Maintenance Tool.exe";
    absPathMaintenanceTool = applicationDir.filePath(maintenanceToolFilename);

    if (!applicationDir.exists(maintenanceToolFilename)) {
        qCCritical(logCategoryCoreUpdate) << maintenanceToolFilename << "not found in" << applicationDir.absolutePath();
        return QString(maintenanceToolFilename + " not found.");
    }

    return QString();
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