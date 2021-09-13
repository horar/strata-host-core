#include "ProgramFirmware.h"

#include "logging/LoggingQtCategories.h"
#include <QJsonDocument>

ProgramFirmware::ProgramFirmware(
        CoreInterface *coreInterface,
        QObject *parent)
    : QObject(parent),
      coreInterface_(coreInterface)
{
    connect(coreInterface_, &CoreInterface::programControllerReply, this, &ProgramFirmware::replyHandler);
    connect(coreInterface_, &CoreInterface::programControllerJobUpdate, this, &ProgramFirmware::jobUpdateHandler);

    connect(coreInterface_, &CoreInterface::updateFirmwareReply, this, &ProgramFirmware::replyHandler);
    connect(coreInterface_, &CoreInterface::updateFirmwareJobUpdate, this, &ProgramFirmware::jobUpdateHandler);
}

ProgramFirmware::~ProgramFirmware()
{
}

bool ProgramFirmware::programAssisted(QString deviceId)
{
    if (requestDevice(deviceId, Action::ProgramAssisted, QString(), QString()) == false) {
        return false;
    }

    QJsonObject cmdPayloadObject {
        { "device_id", deviceId }
    };

    QJsonObject cmdMessageObject {
        { "hcs::cmd", "program_controller" },
        { "payload", cmdPayloadObject }
    };

    QJsonDocument doc(cmdMessageObject);

    coreInterface_->sendCommand(doc.toJson(QJsonDocument::Compact));

    return true;
}

bool ProgramFirmware::programEmbedded(QString deviceId)
{
    if (requestDevice(deviceId, Action::ProgramEmbedded, QString(), QString()) == false) {
        return false;
    }

    flashFirmware(deviceId, QString(), QString(), false);

    return true;
}

bool ProgramFirmware::programSpecificFirmware(QString deviceId, QString firmwareUri, QString firmwareMD5)
{
    if (requestDevice(deviceId, Action::ProgramSpecificFirmware, firmwareUri, firmwareMD5) == false) {
        return false;
    }

    flashFirmware(deviceId, firmwareUri, firmwareMD5, true);

    return true;
}

void ProgramFirmware::flashFirmware(const QString& deviceId, const QString& firmwareUri, const QString& firmwareMD5, bool specific)
{
    QJsonObject cmdPayloadObject {
        { "device_id", deviceId }
    };

    if (specific) {
        cmdPayloadObject.insert("path", firmwareUri);
        cmdPayloadObject.insert("md5", firmwareMD5);
    }

    QJsonObject cmdMessageObject {
        { "hcs::cmd", "update_firmware" },
        { "payload", cmdPayloadObject }
    };

    QJsonDocument doc(cmdMessageObject);

    coreInterface_->sendCommand(doc.toJson(QJsonDocument::Compact));
}

bool ProgramFirmware::requestDevice(const QString& deviceId, Action action, const QString& firmwareUri, const QString& firmwareMD5)
{
    if (deviceId.isEmpty()) {
        qCCritical(logCategoryStrataDevStudio) << "Bad request, device ID is empty.";
        return false;
    }

    if (requestedDevices_.contains(deviceId)) {
        qCCritical(logCategoryStrataDevStudio) << "Request for an already processed device ID" << deviceId;
        return false;
    }

    requestedDevices_.insert(deviceId, FlashingData(action, firmwareUri, firmwareMD5));

    return true;
}

QJsonObject ProgramFirmware::acquireProgramFirmwareData(QString deviceId, QString firmwareUri, QString firmwareMD5) const
{
    QJsonObject payload;

    auto deviceIter = requestedDevices_.find(deviceId);
    if (deviceIter == requestedDevices_.end()) {
        return payload;
    }

    if ((deviceIter.value().uri == firmwareUri) && (deviceIter.value().md5 == firmwareMD5)) {
        payload.insert("status", deviceIter.value().status);
        payload.insert("progress", deviceIter.value().progress);
    }

    return payload;
}

void ProgramFirmware::replyHandler(QJsonObject payload)
{
    const QString deviceId = payload.value(QStringLiteral("device_id")).toString();
    if (deviceId.isEmpty()) {
        qCCritical(logCategoryStrataDevStudio) << "Bad reply, device ID is missing.";
        return;
    }

    auto requestedDevice = requestedDevices_.find(deviceId);
    if (requestedDevice == requestedDevices_.end()) {
        // not our request
        return;
    }

    if (payload.contains(QStringLiteral("error_string"))) {
        const QString errorString = acquireErrorString(payload);
        emit jobError(deviceId, errorString);
        emit jobFinished(deviceId, errorString);
        requestedDevices_.erase(requestedDevice);
        return;
    }

    if (requestedDevice.value().uri.isEmpty()) {
        requestedDevice.value().uri = payload.value(QStringLiteral("path")).toString();
    }
    if (requestedDevice.value().md5.isEmpty()) {
        requestedDevice.value().md5 = payload.value(QStringLiteral("md5")).toString();
    }

    const QString jobId = payload.value(QStringLiteral("job_id")).toString();
    if (jobId.isEmpty()) {
        const QString errorString = QStringLiteral("Bad reply, job ID is missing.");
        qCCritical(logCategoryStrataDevStudio).noquote() << errorString << "Device ID:" << deviceId;
        emit jobError(deviceId, errorString);
        return;
    }

    jobIdHash_.insert(jobId, deviceId);

    emit jobStarted(deviceId, requestedDevice.value().uri, requestedDevice.value().md5);
}

void ProgramFirmware::jobUpdateHandler(QJsonObject payload)
{
    if ((payload.contains("job_id") == false) ||
        (payload.contains("job_type") == false) ||
        (payload.contains("job_status") == false)) {
        qCCritical(logCategoryStrataDevStudio) << "Badly formatted JSON, job data is missing.";
        return;
    }

    const QString jobId = payload.value(QStringLiteral("job_id")).toString();

    auto jobIter = jobIdHash_.find(jobId);
    if (jobIter == jobIdHash_.end()) {
        // not our request
        return;
    }

    const QString deviceId = jobIter.value();
    auto deviceIter = requestedDevices_.find(deviceId);
    if (deviceIter == requestedDevices_.end()) {
        const QString errorString = QStringLiteral("Unexpected internal error");
        emit jobError(deviceId, errorString);
        emit jobFinished(deviceId, errorString);
        jobIdHash_.erase(jobIter);
    }

    bool finished;
    const Action action = deviceIter.value().action;

    switch (action) {
    case Action::ProgramAssisted :
        finished = programAssistedController(deviceIter, payload);
        break;
    case Action::ProgramEmbedded :
        finished = programFirmware(deviceIter, payload);
        break;
    case Action::ProgramSpecificFirmware :
        finished = backupAndProgram(deviceIter, payload);
        break;
    }

    if (finished) {
        jobIdHash_.erase(jobIter);
        requestedDevices_.erase(deviceIter);
    }
}

bool ProgramFirmware::programAssistedController(const QHash<QString,FlashingData>::Iterator deviceIter, const QJsonObject& payload)
{
    // Download -> Prepare -> ClearFwClassId -> (Flash) -> SetFwClassId -> Finished

    // If the firmware that should be flashed is the same as the current firmware on the platform, the 'Flash' step will be skipped.

    bool finished = false;
    const JobType jobType = acquireJobType(payload);

    switch (jobType) {
    case JobType::Prepare :
        simpleJob(jobType, deviceIter, payload, 0.5f);
        break;
    case JobType::ClearFwClassId :
    case JobType::SetFwClassId :
        simpleJob(jobType, deviceIter, payload, 1.0f);
        break;
    case JobType::Download :
    case JobType::Flash :
        progressJob(jobType, deviceIter, payload);
        break;
    case JobType::Finished :
        finishedJob(deviceIter, payload);
        finished = true;
        break;
    default :
        logError(QStringLiteral("Unknown job type"), deviceIter.key(), deviceIter.value().action, jobType);
        break;
    }

    return finished;
}

bool ProgramFirmware::programFirmware(const QHash<QString,FlashingData>::Iterator deviceIter, const QJsonObject& payload)
{
    // Download -> Prepare -> Flash -> Finished

    bool finished = false;
    const JobType jobType = acquireJobType(payload);

    switch (jobType) {
    case JobType::Prepare :
        simpleJob(jobType, deviceIter, payload, 0.5f);
        break;
    case JobType::Download :
    case JobType::Flash :
        progressJob(jobType, deviceIter, payload);
        break;
    case JobType::Finished :
        finishedJob(deviceIter, payload);
        finished = true;
        break;
    default :
        logError(QStringLiteral("Unknown job type"), deviceIter.key(), deviceIter.value().action, jobType);
        break;
    }

    return finished;
}

bool ProgramFirmware::backupAndProgram(const QHash<QString,FlashingData>::Iterator deviceIter, const QJsonObject& payload)
{
    // Download -> Prepare -> Backup -> (ClearFwClassId) -> Flash -> (Restore) -> (SetFwClassId) -> Finished

    // If flashing assisted platfomr, there are 'ClearFwClassId' and 'SetFwClassId' steps.
    // If 'Flash' fails, backed up firmware is restored (flashed back to platform).

    bool finished = false;
    const JobType jobType = acquireJobType(payload);

    switch (jobType) {
    case JobType::Prepare :
        simpleJob(jobType, deviceIter, payload, 0.5f);
        break;
    case JobType::ClearFwClassId :
    case JobType::SetFwClassId :
        simpleJob(jobType, deviceIter, payload, 1.0f);
        break;
    case JobType::Download :
    case JobType::Backup :
    case JobType::Flash :
    case JobType::Restore :
        progressJob(jobType, deviceIter, payload);
        break;
    case JobType::Finished :
        finishedJob(deviceIter, payload);
        finished = true;
        break;
    default :
        logError(QStringLiteral("Unknown job type"), deviceIter.key(), deviceIter.value().action, jobType);
        break;
    }

    return finished;
}

void ProgramFirmware::simpleJob(JobType jobType, const QHash<QString,FlashingData>::Iterator deviceIter, const QJsonObject& payload, float progress)
{
    const JobStatus jobStatus = acquireJobStatus(payload);
    if (jobStatus == JobStatus::Running) {
        notifyProgressChange(deviceIter, jobType, progress);
    } else if (jobStatus == JobStatus::Failure) {
        emit jobError(deviceIter.key(), acquireErrorString(payload));
    } else {
        logError(QStringLiteral("Unknown job status"), deviceIter.key(), deviceIter.value().action, jobType);
    }
}

void ProgramFirmware::progressJob(JobType jobType, const QHash<QString,FlashingData>::Iterator deviceIter, const QJsonObject& payload)
{
    const JobStatus jobStatus = acquireJobStatus(payload);
    if (jobStatus == JobStatus::Running) {
        QJsonValue totalValue = payload.value(QStringLiteral("total"));
        QJsonValue completeValue = payload.value(QStringLiteral("complete"));

        if (totalValue.isUndefined() || completeValue.isUndefined()) {
            logError(QStringLiteral("Badly formatted JSON"), deviceIter.key(), deviceIter.value().action, jobType);
            return;
        }

        int total = totalValue.toInt();
        int complete = completeValue.toInt();
        float progress = (total > 0)
                         ? static_cast<float>(complete) / static_cast<float>(total)
                         : 0.0f;

        notifyProgressChange(deviceIter, jobType, progress);
    } else if (jobStatus == JobStatus::Failure) {
        emit jobError(deviceIter.key(), acquireErrorString(payload));
    } else {
        logError(QStringLiteral("Unknown job status"), deviceIter.key(), deviceIter.value().action, jobType);
    }
}

void ProgramFirmware::finishedJob(const QHash<QString,FlashingData>::Iterator deviceIter, const QJsonObject& payload)
{
    QString errorString;
    const JobStatus jobStatus = acquireJobStatus(payload);
    if (jobStatus == JobStatus::Success) {
        notifyProgressChange(deviceIter, JobType::Finished, 1.0f);
    } else if (jobStatus == JobStatus::Failure || jobStatus == JobStatus::Unsuccess) {
        errorString = acquireErrorString(payload);
        emit jobError(deviceIter.key(), errorString);
    } else {
        errorString = QStringLiteral("Unknown job finish status");
        logError(errorString, deviceIter.key(), deviceIter.value().action, JobType::Finished);
    }
    emit jobFinished(deviceIter.key(), errorString);
}

QString ProgramFirmware::acquireErrorString(const QJsonObject& payload) const
{
    const QString errorString = payload.value(QStringLiteral("error_string")).toString();
    return errorString.isEmpty() ? QStringLiteral("Unknown error") : errorString;
}

ProgramFirmware::JobType ProgramFirmware::acquireJobType(const QJsonObject& payload) const
{
    const QString jobType = payload.value("job_type").toString();

    if (jobType.isEmpty()) {
        return JobType::Unknown;
    } else if (jobType == QStringLiteral("download_progress")) {
        return JobType::Download;
    } else if (jobType == QStringLiteral("flash_progress")) {
        return JobType::Flash;
    } else if (jobType == QStringLiteral("backup_progress")) {
        return JobType::Backup;
    } else if (jobType == QStringLiteral("prepare")) {
        return JobType::Prepare;
    } else if (jobType == QStringLiteral("finished")) {
        return JobType::Finished;
    } else if (jobType == QStringLiteral("clear_fw_class_id")) {
        return JobType::ClearFwClassId;
    } else if (jobType == QStringLiteral("set_fw_class_id")) {
        return JobType::SetFwClassId;
    } else if (jobType == QStringLiteral("restore_progress")) {
        return JobType::Restore;
    }

    return JobType::Unknown;
}

ProgramFirmware::JobStatus ProgramFirmware::acquireJobStatus(const QJsonObject& payload) const
{
    const QString jobStatus = payload.value(QStringLiteral("job_status")).toString();

    if (jobStatus.isEmpty()) {
        return JobStatus::Unknown;
    } else if (jobStatus == QStringLiteral("running")) {
        return JobStatus::Running;
    } else if (jobStatus == QStringLiteral("success")) {
        return JobStatus::Success;
    } else if (jobStatus == QStringLiteral("unsuccess")) {
        return JobStatus::Unsuccess;
    } else if (jobStatus == QStringLiteral("failure")) {
        return JobStatus::Failure;
    }

    return JobStatus::Unknown;
}

void ProgramFirmware::notifyProgressChange(const QHash<QString,FlashingData>::Iterator deviceIter, JobType jobType, float progress)
{
    float overallProgress = resolveOverallProgress(deviceIter.value().action, jobType, progress);
    QString status = resolveStatus(jobType, progress);

    deviceIter.value().progress = overallProgress;
    deviceIter.value().status = status;

    emit jobProgressUpdate(deviceIter.key(), status, overallProgress);
}

float ProgramFirmware::resolveOverallProgress(Action action, JobType jobType, float progress) const
{
    // 0.99 together
    constexpr float downloadRange = 0.10f;
    constexpr float prepareRange = 0.05f;
    float clearDataRange = 0.0f, backupRange = 0.0f, programRange = 0.0f, setDataRange = 0.0f;

    switch (action) {
    case Action::ProgramAssisted :
        // Download -> Prepare -> ClearFwClassId -> (Flash) -> SetFwClassId -> Finished
        clearDataRange = 0.02f;
        programRange = 0.80f;
        setDataRange = 0.02f;
        break;
    case Action::ProgramEmbedded :
        // Download -> Prepare -> Flash -> Finished
        programRange = 0.84f;
        break;
    case Action::ProgramSpecificFirmware :
        // Download -> Prepare -> Backup -> (ClearFwClassId) -> Flash -> (Restore) -> (SetFwClassId) -> Finished
        backupRange = 0.40f;
        clearDataRange = 0.02f;
        programRange = 0.40f;
        setDataRange = 0.02f;
        break;
    }

    float overallProgress = 0.0f;

    switch(jobType) {
    case JobType::Download :
        overallProgress = downloadRange * progress;
        break;
    case JobType::Prepare :
        overallProgress = downloadRange + (prepareRange * progress);
        break;
    case JobType::ClearFwClassId :
        overallProgress = downloadRange + prepareRange + (clearDataRange * progress);
        break;
    case JobType::Backup :
        overallProgress = downloadRange + prepareRange + clearDataRange + (backupRange * progress);
        break;
    case JobType::Flash :
    case JobType::Restore :
        overallProgress = downloadRange + prepareRange + clearDataRange + backupRange + (programRange * progress);
        break;
    case JobType::SetFwClassId :
        overallProgress = downloadRange + prepareRange + clearDataRange + backupRange + programRange + (setDataRange * progress);
        break;
    case JobType::Finished :
        overallProgress = 1.0f;
        break;
    case JobType::Unknown :
        break;
    }

    return overallProgress;
}

QString ProgramFirmware::resolveStatus(JobType jobType, float progress) const
{
    QString status;

    switch(jobType) {
    case JobType::Download :
        status = QStringLiteral("Downloading");
        break;
    case JobType::Prepare :
        status = QStringLiteral("Preparing...");
        break;
    case JobType::ClearFwClassId :
        status = QStringLiteral("Clearing data...");
        break;
    case JobType::Backup :
        status = QStringLiteral("Backing up");
        break;
    case JobType::Flash :
        status = QStringLiteral("Programming");
        break;
    case JobType::Restore :
        status = QStringLiteral("Restoring original");
        break;
    case JobType::SetFwClassId :
        status = QStringLiteral("Setting data...");
        break;
    case JobType::Finished :
        status = QStringLiteral("Done");
        break;
    case JobType::Unknown :
        break;
    }

    if (jobType == JobType::Download ||
        jobType == JobType::Backup ||
        jobType == JobType::Flash ||
        jobType == JobType::Restore)
    {
        status += QStringLiteral(" firmware (") + QString::number(static_cast<int>(progress * 100.0f)) + QStringLiteral("%)");
    }

    return status;
}

void ProgramFirmware::logError(const QString& errorString, const QString& deviceId, Action action, JobType jobType)
{
    qCWarning(logCategoryStrataDevStudio).noquote().nospace() << errorString << ", device ID: " << deviceId
        << " (action " << static_cast<int>(action) << ", job type " << static_cast<int>(jobType) << ").";
}
