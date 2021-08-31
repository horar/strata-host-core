#include "FirmwareManager.h"

#include "logging/LoggingQtCategories.h"
#include <QJsonDocument>

FirmwareManager::FirmwareManager(
        strata::strataRPC::StrataClient *strataClient,
        CoreInterface *coreInterface,
        QObject *parent)
    : QObject(parent),
      strataClient_(strataClient),
      coreInterface_(coreInterface)
{
    connect(coreInterface_, &CoreInterface::updateFirmwareReply, this, &FirmwareManager::replyHandler);
    connect(coreInterface_, &CoreInterface::updateFirmwareJobUpdate, this, &FirmwareManager::jobUpdateHandler);
}

FirmwareManager::~FirmwareManager()
{
}

bool FirmwareManager::updateFirmware(QString deviceId, QString uri, QString md5)
{
    if (deviceId.isEmpty()) {
        qCCritical(logCategoryStrataDevStudio) << "badly formatted updateFirmware request, deviceId is missing";
        return false;
    }

    if (deviceData_.contains(deviceId) == true) {
        // wait for existing flashing to end
        qCWarning(logCategoryStrataDevStudio) << "Unable to start flashing, previous flash operation has not ended";
        return false;
    }

    QJsonObject cmdPayloadObject;
    cmdPayloadObject.insert("device_id", deviceId);
    cmdPayloadObject.insert("path", uri);
    cmdPayloadObject.insert("md5", md5);

    deviceData_.insert(deviceId, {uri, md5, QString(), QString(), QString(), 0.0});

    strataClient_->sendRequest("update_firmware", cmdPayloadObject);
    return true;
}

QJsonObject FirmwareManager::acquireUpdateFirmwareData(QString deviceId, QString uri, QString md5) const
{
    QJsonObject payload;
    auto iter = deviceData_.find(deviceId);
    if (iter == deviceData_.end()) {
        return payload;
    }

    if ((iter->uri_ == uri) && (iter->md5_ == md5)) {
        payload.insert("status", iter->status_);
        payload.insert("progress", iter->progress_);
    }

    return payload;
}

void FirmwareManager::replyHandler(QJsonObject payload)
{
    if (payload.contains("device_id") == false) {
        qCCritical(logCategoryStrataDevStudio) << "Badly formatted json, device_id is missing";
        return;
    }

    QString deviceId = payload.value("device_id").toString();
    auto iter = deviceData_.find(deviceId);
    if (iter == deviceData_.end()) {
        // not our request
        qCDebug(logCategoryStrataDevStudio) << "Externally started flash operation detected, ignoring";
        return;
    }

    if (iter.value().jobId_.isEmpty() == false) {
        // should not happen, probably externally started flashing
        qCWarning(logCategoryStrataDevStudio) << "Invalid updateFirmware reply detected, previous flash operation has not ended";
        return;
    }

    if (payload.contains("job_id")) {
        QString jobId = payload.value("job_id").toString();
        if (jobId.isEmpty()) {
            qCCritical(logCategoryStrataDevStudio) << "Badly formatted updateFirmware reply, job_id is empty";
            return;
        }

        if (jobIdHash_.contains(jobId)) {
            QString errorString = "Collision on jobId detected.";
            emit updateFirmwareJobFinished(deviceId, "Init failed: " + errorString, errorString);
            deviceData_.erase(iter);
            return;
        }

        jobIdHash_.insert(jobId, deviceId);
        iter.value().jobId_ = jobId;
    } else {
        QString errorString = acquireErrorString(payload);
        emit updateFirmwareJobFinished(deviceId, "Init failed: " + errorString, errorString);
        deviceData_.erase(iter);
        return;
    }
}

void FirmwareManager::jobUpdateHandler(QJsonObject payload)
{
    if ((payload.contains("job_id") == false) ||
        (payload.contains("job_type") == false) ||
        (payload.contains("job_status") == false)) {
        qCCritical(logCategoryStrataDevStudio) << "Badly formatted json, job data is missing";
        return;
    }

    QString jobId = payload.value("job_id").toString();
    QString jobType = payload.value("job_type").toString();
    QString jobStatus = payload.value("job_status").toString();

    auto jobIter = jobIdHash_.find(jobId);
    if (jobIter == jobIdHash_.end()) {
        // not our request
        return;
    }

    QString deviceId = jobIter.value();
    auto deviceIter = deviceData_.find(deviceId);
    if ((deviceIter == deviceData_.end()) ||
        (deviceIter->jobId_ != jobId)) {
        // not our request
        return;
    }

    if (jobType == "prepare") {
        if (jobStatus == "running") {
            deviceIter->status_ = "Preparing...";
            deviceIter->progress_ = resolveOverallProgress(ProgressState::PrepareState);
            emit updateFirmwareJobProgress(deviceId, deviceIter->status_, deviceIter->progress_);
        } else if (jobStatus == "failure") {
            QString errorString = acquireErrorString(payload);
            deviceIter->status_ = "Preparation failed";
            if (errorString.isEmpty() == false) {
                deviceIter->error_ = errorString;
                deviceIter->status_ += ": " + errorString;
            }
            emit updateFirmwareJobProgress(deviceId, deviceIter->status_, deviceIter->progress_);
        } else {
            qCWarning(logCategoryStrataDevStudio) << "unknown job status";
        }
    } else if ((jobType == "flash_progress") || (jobType == "restore_progress") ||
               (jobType == "download_progress") || (jobType == "backup_progress")) {
        QString jobName;
        ProgressState jobState;
        if (jobType == "flash_progress") {
            jobName = "Flashing";
            jobState = ProgressState::ProgramState;
        } else if (jobType == "restore_progress") {
            jobName = "Restoring";
            jobState = ProgressState::ProgramState;
        } else if (jobType == "download_progress") {
            jobName = "Downloading";
            jobState = ProgressState::DownloadState;
        } else {
            jobName = "Backing up";
            jobState = ProgressState::BackupState;
        }

        if (jobStatus == "running") {
            if ((payload.contains("total") == false) || (payload.contains("complete") == false)) {
                qCCritical(logCategoryStrataDevStudio) << "Badly formatted json, data is missing";
                return;
            }

            deviceIter->status_ = jobName + " firmware... ";
            int total = payload.value("total").toInt();
            int complete = payload.value("complete").toInt();
            float progress = (total > 0) ? ((float)complete / (float)total) : 0.0;

            deviceIter->progress_ = resolveOverallProgress(jobState, progress);
            deviceIter->status_ += QString::number((int)(100.0 * progress)) + "% complete";

            emit updateFirmwareJobProgress(deviceId, deviceIter->status_, deviceIter->progress_);
        } else if (jobStatus == "failure") {
            QString errorString = acquireErrorString(payload);
            deviceIter->status_ = jobName + " failed";
            if (errorString.isEmpty() == false) {
                deviceIter->error_ = errorString;
                deviceIter->status_ += ": " + errorString;
            }
            emit updateFirmwareJobProgress(deviceId, deviceIter->status_, deviceIter->progress_);
        } else {
            qCWarning(logCategoryStrataDevStudio) << "unknown job status";
        }
    } else if (jobType == "finished") {
        deviceIter->status_ = "Done";
        deviceIter->progress_ = resolveOverallProgress(ProgressState::DoneState);
        emit updateFirmwareJobProgress(deviceId, deviceIter->status_, deviceIter->progress_);
        if (jobStatus == "success") {
            emit updateFirmwareJobFinished(deviceId, "Firmware installation succeeded", QString());
        } else if (jobStatus == "failure" || jobStatus == "unsuccess") {
            QString errorString = acquireErrorString(payload);
            QString finalStatus = "Firmware installation failed";
            if (errorString.isEmpty() && (deviceIter->error_.isEmpty() == false)) {
                // the error might be mentioned in the job type that failed, not in the "finished" job type
                errorString = deviceIter->error_;
            }
            if (errorString.isEmpty() == false) {
                finalStatus += ": " + errorString;
            }
            emit updateFirmwareJobFinished(deviceId, finalStatus, errorString);
        } else {
            qCWarning(logCategoryStrataDevStudio) << "unknown job status";
        }

        jobIdHash_.erase(jobIter);
        deviceData_.erase(deviceIter);
    } else {
        qCWarning(logCategoryStrataDevStudio) << "unknown job_type" << jobType;
    }
}

float FirmwareManager::resolveOverallProgress(FirmwareManager::ProgressState state, float stateProgress)
{
    float overallProgress = 0.0;

    switch(state) {
    case ProgressState::DownloadState:
        overallProgress = downloadStateRange_ * stateProgress;
        break;
    case ProgressState::PrepareState:
        overallProgress = downloadStateRange_ + prepareStateRange_ * stateProgress;
        break;
    case ProgressState::BackupState:
        overallProgress = downloadStateRange_ + prepareStateRange_ + backupStateRange_ * stateProgress;
        break;
    case ProgressState::ProgramState:
        overallProgress = downloadStateRange_ + prepareStateRange_ + backupStateRange_ + programStateRange_ * stateProgress;
        break;
    case ProgressState::DoneState:
        overallProgress = 1.0;
        break;
    default:
        qCWarning(logCategoryStrataDevStudio) << "unknown progress state";
    }

    return overallProgress;
}

QString FirmwareManager::acquireErrorString(const QJsonObject &payload)
{
    if (payload.contains("error_string")) {
        return payload.value("error_string").toString();    // sometimes can be empty
    } else {
        return "Badly formatted json.";
    }
}
