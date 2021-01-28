#include "AdjustControllerManager.h"

#include "logging/LoggingQtCategories.h"
#include <QJsonDocument>

AdjustControllerManager::AdjustControllerManager(
        CoreInterface *coreInterface,
        QObject *parent)
    : QObject(parent),
      coreInterface_(coreInterface)
{
    connect(coreInterface_, &CoreInterface::adjustControllerReply, this, &AdjustControllerManager::replyHandler);
    connect(coreInterface_, &CoreInterface::adjustControllerJobUpdate, this, &AdjustControllerManager::jobUpdateHandler);
}

AdjustControllerManager::~AdjustControllerManager()
{
}

void AdjustControllerManager::adjustController(int deviceId)
{
    QJsonObject cmdPayloadObject;
    cmdPayloadObject.insert("device_id",deviceId);

    QJsonObject cmdMessageObject;
    cmdMessageObject.insert("hcs::cmd", "adjust_controller");
    cmdMessageObject.insert("payload", cmdPayloadObject);

    QJsonDocument doc(cmdMessageObject);
    QString strJson(doc.toJson(QJsonDocument::Compact));

    requestedDeviceIds_.append(deviceId);

    coreInterface_->sendCommand(strJson);
}

void AdjustControllerManager::replyHandler(QJsonObject message)
{
     QJsonObject payload = message.value("payload").toObject();

    if (payload.contains("device_id") == false) {
        qCCritical(logCategoryStrataDevStudio) << "badly formatter json, device_id is missing";
        return;
    }

    int deviceId = payload.value("device_id").toInt();
    if (requestedDeviceIds_.contains(deviceId) == false) {
        //not our request
        return;
    }

    if (payload.contains("job_id")) {
        QString jobId = payload.value("job_id").toString();
        jobIdHash_.insert(jobId, deviceId);
    } else {
        notifyFailure(deviceId, payload);
    }

    requestedDeviceIds_.removeAll(deviceId);

    emit jobStatusChanged(deviceId, "running", "");
}

void AdjustControllerManager::jobUpdateHandler(QJsonObject message)
{
    QJsonObject payload = message.value("payload").toObject();

    QString jobId = payload.value("job_id").toString();
    QString jobType = payload.value("job_type").toString();
    QString jobStatus = payload.value("job_status").toString();

    int deviceId = jobIdHash_.value(jobId);

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

    } else if (jobType == "flash_progress") {
        if (jobStatus == "running") {
            if (payload.contains("total") == false || payload.contains("complete") == false) {
                qCCritical(logCategoryStrataDevStudio) << "badly formatted json";
                return;
            }

            int total = payload.value("total").toInt();
            int complete = payload.value("complete").toInt();

            notifyProgressChange(deviceId, ProgressState::ProgramState, complete/(float)total);
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
        } else if (jobStatus == "failure") {
            emit jobStatusChanged(deviceId, "failure", payload.value("error_string").toString());
        } else {
            qCWarning(logCategoryStrataDevStudio) << "unknown job status";
        }

        jobIdHash_.remove(jobId);

    } else {
        qCWarning(logCategoryStrataDevStudio) << "unknown job_type" << jobType;
    }
}

void AdjustControllerManager::notifyProgressChange(int deviceId, AdjustControllerManager::ProgressState state, float stateProgress)
{
    float progress = resolveOverallProgress(state, stateProgress);
    emit jobProgressUpdate(deviceId, progress);
}

void AdjustControllerManager::notifyFailure(int deviceId, const QJsonObject &payload)
{
    QString errorString = payload.value("error_string").toString();
    emit jobStatusChanged(deviceId, "failure", errorString);
}

float AdjustControllerManager::resolveOverallProgress(AdjustControllerManager::ProgressState state, float stateProgress)
{
    float overallProgress = 0.0;

    switch(state) {
    case ProgressState::DownloadState:
        overallProgress = downloadStateRange_ * stateProgress;
        break;
    case ProgressState::ClearDataState:
        overallProgress = downloadStateRange_ + clearDataStateRange_ * stateProgress;
        break;
    case ProgressState::PrepareState:
        overallProgress = downloadStateRange_ + clearDataStateRange_ + prepareStateRange_ * stateProgress;
        break;
    case ProgressState::ProgramState:
        overallProgress = downloadStateRange_ + clearDataStateRange_ + prepareStateRange_ + programStateRange_ * stateProgress;
        break;
    case ProgressState::SetDataState:
        overallProgress = downloadStateRange_ + clearDataStateRange_ + prepareStateRange_ + programStateRange_ + setDataStateRange_ * stateProgress;
        break;
    case ProgressState::DoneState:
        overallProgress = 1.0;
        break;
    default:
        qCWarning(logCategoryStrataDevStudio) << "unknown progress state";
    }

    return overallProgress;
}
