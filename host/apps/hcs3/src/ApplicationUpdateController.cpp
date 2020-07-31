#include "ApplicationUpdateController.h"
#include "logging/LoggingQtCategories.h"

#include <QCoreApplication>
#include <QStringList>
#include <QProcess>
#include <QDir>

#if defined(Q_OS_WIN)
    #define STRATA_MAINTENANCE_TOOL QString("Strata Maintenance Tool.exe")
#elif defined(Q_OS_MACOS)
    #define STRATA_MAINTENANCE_TOOL QString("Strata Maintenance Tool.app")
#elif defined(Q_OS_LINUX
    #define STRATA_MAINTENANCE_TOOL QString("Strata Maintenance Tool.app")
#endif

ApplicationUpdateController::ApplicationUpdateController(QObject *parent) : QObject(parent)
{

}

void ApplicationUpdateController::updateApplication(const QByteArray &clientId)
{
    QDir applicationDir(QCoreApplication::applicationDirPath());
    if(!applicationDir.exists(STRATA_MAINTENANCE_TOOL)) {
        QString errStr(STRATA_MAINTENANCE_TOOL + " not found in " + applicationDir.absolutePath());
        qCCritical(logCategoryHcs) << errStr;
        emit executionOfUpdate(clientId, errStr);
        return;
    }

    QString program = applicationDir.absoluteFilePath(STRATA_MAINTENANCE_TOOL);
    QStringList arguments;
    arguments << "isSilent=true" << "forceUpdate=true" << "delayStart=3000";

    QProcess maintenanceToolProcess;
    maintenanceToolProcess.setProgram(program);
    maintenanceToolProcess.setArguments(arguments);
    maintenanceToolProcess.setWorkingDirectory(applicationDir.absolutePath());
    maintenanceToolProcess.startDetached();

    qCDebug(logCategoryHcs) << ("Started " + STRATA_MAINTENANCE_TOOL);
    emit executionOfUpdate(clientId, "");
}
