#include "PrtModel.h"
#include "logging/LoggingQtCategories.h"

PrtModel::PrtModel(QObject *parent)
    : QObject(parent)
{
    boardManager_.init();

    connect(&boardManager_, &strata::BoardManager::boardReady, this, &PrtModel::boardReadyHandler);
    connect(&boardManager_, &strata::BoardManager::boardDisconnected, this, &PrtModel::boardDisconnectedHandler);
}

PrtModel::~PrtModel()
{
}

int PrtModel::deviceCount() const
{
    return platformList_.length();
}

QString PrtModel::deviceFirmwareVersion() const
{
    if (platformList_.isEmpty()) {
        return "";
    }

    return platformList_.first()->property(strata::device::DeviceProperties::applicationVer);
}

QString PrtModel::deviceFirmwareVerboseName() const
{
    if (platformList_.isEmpty()) {
        return "";
    }

    return platformList_.first()->property(strata::device::DeviceProperties::verboseName);
}

QString PrtModel::programDevice(QString filePath)
{
    QString errorString;

    if (platformList_.isEmpty()) {
        errorString = "No platform connected";
    } else if (platformList_.length() > 1) {
        errorString = "More than one platform is connected";
    } else if (flasherConnector_.isNull() == false) {
        errorString = "Programming already in progress";
    }

    if (errorString.isEmpty() == false) {
        qCCritical(logCategoryPrt) << errorString;
        return errorString;
    }

    flasherConnector_ = new strata::FlasherConnector(platformList_.first(), filePath, this);

    connect(flasherConnector_, &strata::FlasherConnector::operationStateChanged, this, &PrtModel::flasherProgress);
    connect(flasherConnector_, &strata::FlasherConnector::finished, this, &PrtModel::flasherFinishedHandler);

    flasherConnector_->flash(false);

    return errorString;
}

void PrtModel::boardReadyHandler(int deviceId, bool recognized)
{
    Q_UNUSED(recognized)

    platformList_.append(boardManager_.device(deviceId));
    emit deviceCountChanged();
    emit boardReady(deviceId);
}

void PrtModel::boardDisconnectedHandler(int deviceId)
{
    int index = 0;
    while (index < platformList_.length()) {
        if (platformList_.at(index)->deviceId() == deviceId) {
            platformList_.removeAt(index);
            emit deviceCountChanged();
            break;
        }

        ++index;
    }

    emit boardDisconnected(deviceId);
}

void PrtModel::flasherFinishedHandler(strata::FlasherConnector::Result result)
{
    emit flasherFinished(result);

    flasherConnector_->disconnect();
    flasherConnector_->deleteLater();
}
