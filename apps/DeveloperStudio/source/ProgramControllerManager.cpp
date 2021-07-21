#include "ProgramControllerManager.h"

#include "logging/LoggingQtCategories.h"
#include <QJsonDocument>

ProgramControllerManager::ProgramControllerManager(
        CoreInterface *coreInterface,
        QObject *parent)
    : QObject(parent),
      coreInterface_(coreInterface)
{
    connect(coreInterface_, &CoreInterface::programControllerReply, this, &ProgramControllerManager::replyHandler);
    connect(coreInterface_, &CoreInterface::programControllerJobUpdate, this, &ProgramControllerManager::jobUpdateHandler);

    connect(coreInterface_, &CoreInterface::updateFirmwareReply, this, &ProgramControllerManager::replyHandler);
    connect(coreInterface_, &CoreInterface::updateFirmwareJobUpdate, this, &ProgramControllerManager::jobUpdateHandler);
}

ProgramControllerManager::~ProgramControllerManager()
{
}


void ProgramControllerManager::programAssisted(QString deviceId)
{
    QJsonObject cmdPayloadObject;
    cmdPayloadObject.insert("device_id", deviceId);

    QJsonObject cmdMessageObject;
    cmdMessageObject.insert("hcs::cmd", "program_controller");
    cmdMessageObject.insert("payload", cmdPayloadObject);

    QJsonDocument doc(cmdMessageObject);
    QString strJson(doc.toJson(QJsonDocument::Compact));

    requestedDeviceIds_.append(deviceId);

    coreInterface_->sendCommand(strJson);
}

void ProgramControllerManager::programEmbedded(QString deviceId)
{
    QJsonObject cmdPayloadObject;
    cmdPayloadObject.insert("device_id", deviceId);

    QJsonObject cmdMessageObject;
    cmdMessageObject.insert("hcs::cmd", "update_firmware");
    cmdMessageObject.insert("payload", cmdPayloadObject);

    QJsonDocument doc(cmdMessageObject);
    QString strJson(doc.toJson(QJsonDocument::Compact));

    requestedDeviceIds_.append(deviceId);

    coreInterface_->sendCommand(strJson);
}

void ProgramControllerManager::replyHandler(QJsonObject payload)
{
    if (payload.contains("device_id") == false) {
        qCCritical(logCategoryStrataDevStudio) << "badly formatted json, device_id is missing";
        return;
    }

    QString deviceId = payload.value("device_id").toString();
    if (requestedDeviceIds_.contains(deviceId) == false) {
        //not our request
        return;
    }

    if (payload.contains("job_id")) {
        QString jobId = payload.value("job_id").toString();
        jobIdHash_.insert(jobId, deviceId);
    } else {
        notifyFailure(deviceId, payload);
        requestedDeviceIds_.removeAll(deviceId);
    }

    emit jobStatusChanged(deviceId, "running", "");
}

void ProgramControllerManager::jobUpdateHandler(QJsonObject payload)
{
    QString jobId = payload.value("job_id").toString();
    QString jobType = payload.value("job_type").toString();
    QString jobStatus = payload.value("job_status").toString();

    QString deviceId = jobIdHash_.value(jobId);

    if (requestedDeviceIds_.contains(deviceId) == false) {
        //not our request
        return;
    }

    if (jobType == "clear_fw_class_id") {
        if (jobStatus == "running") {
            notifyProgressChange(deviceId, ProgressState::ClearDataState, 1);
        } else if (jobStatus == "failure") {
            notifyFailure(deviceId, payload);
        } else {
            qCWarning(logCategoryStrataDevStudio) << "unknown job status";
        }
    } else if (jobType == "prepare") {
        if (jobStatus == "running") {
            notifyProgressChange(deviceId, ProgressState::PrepareState, 0.5);
        } else if (jobStatus == "failure") {
            notifyFailure(deviceId, payload);
        } else {
            qCWarning(logCategoryStrataDevStudio) << "unknown job status";
        }
    } else if (jobType == "download_progress") {
        if (jobStatus == "running") {
            if (payload.contains("total") == false || payload.contains("complete") == false) {
                qCCritical(logCategoryStrataDevStudio) << "badly formatted json";
                return;
            }

            int total = payload.value("total").toInt();
            int complete = payload.value("complete").toInt();

            notifyProgressChange(deviceId, ProgressState::DownloadState, complete/(float)total);
        } else if (jobStatus == "failure") {
           notifyFailure(deviceId, payload);
        } else {
            qCWarning(logCategoryStrataDevStudio) << "unknown job status";
        }

    } else if (jobType == "flash_progress" || jobType == "restore_progress") {
        if (jobStatus == "running") {
            if (payload.contains("total") == false || payload.contains("complete") == false) {
                qCCritical(logCategoryStrataDevStudio) << "badly formatted json";
                return;
            }

            int total = payload.value("total").toInt();
            int complete = payload.value("complete").toInt();

            float progress;
            if (total <= 0) {
                progress = 0;
            } else {
                progress = complete/(float)total;
            }

            notifyProgressChange(deviceId, ProgressState::ProgramState, progress);
        } else if (jobStatus == "failure") {
            notifyFailure(deviceId, payload);
        } else {
            qCWarning(logCategoryStrataDevStudio) << "unknown job status";
        }
    } else if (jobType == "set_fw_class_id") {
        if (jobStatus == "running") {
            notifyProgressChange(deviceId, ProgressState::SetDataState, 1);
        } else if (jobStatus == "failure") {
            notifyFailure(deviceId, payload);
        } else {
            qCWarning(logCategoryStrataDevStudio) << "unknown job status";
        }
    } else if (jobType == "finished") {
        if (jobStatus == "success") {
            notifyProgressChange(deviceId, ProgressState::DoneState, 1);
        } else if (jobStatus == "failure" || jobStatus == "unsuccess") {
            emit jobStatusChanged(deviceId, "failure", payload.value("error_string").toString());
        } else {
            qCWarning(logCategoryStrataDevStudio) << "unknown job status";
        }

        jobIdHash_.remove(jobId);
        requestedDeviceIds_.removeAll(deviceId);

    } else {
        qCWarning(logCategoryStrataDevStudio) << "unknown job_type" << jobType;
    }
}

void ProgramControllerManager::notifyProgressChange(const QString &deviceId, ProgramControllerManager::ProgressState state, float stateProgress)
{
    float progress = resolveOverallProgress(state, stateProgress);
    emit jobProgressUpdate(deviceId, progress);
}

void ProgramControllerManager::notifyFailure(const QString &deviceId, const QJsonObject &payload)
{
    QString errorString = payload.value("error_string").toString();
    emit jobStatusChanged(deviceId, "failure", errorString);
}

float ProgramControllerManager::resolveOverallProgress(ProgramControllerManager::ProgressState state, float stateProgress)
{
    float overallProgress = 0.0;

    switch(state) {
    case ProgressState::DownloadState:
        overallProgress = downloadStateRange_ * stateProgress;
        break;
    case ProgressState::PrepareState:
        overallProgress = downloadStateRange_ + prepareStateRange_ * stateProgress;
        break;
    case ProgressState::ClearDataState:
        overallProgress = downloadStateRange_ + prepareStateRange_ + clearDataStateRange_ * stateProgress;
        break;
    case ProgressState::ProgramState:
        overallProgress = downloadStateRange_ + prepareStateRange_ + clearDataStateRange_ + programStateRange_ * stateProgress;
        break;
    case ProgressState::SetDataState:
        overallProgress = downloadStateRange_ + prepareStateRange_ + clearDataStateRange_ + programStateRange_ + setDataStateRange_ * stateProgress;
        break;
    case ProgressState::DoneState:
        overallProgress = 1.0;
        break;
    default:
        qCWarning(logCategoryStrataDevStudio) << "unknown progress state";
    }

    return overallProgress;
}
