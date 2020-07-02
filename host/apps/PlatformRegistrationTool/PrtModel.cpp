#include "PrtModel.h"
#include "logging/LoggingQtCategories.h"

#include <QDir>

PrtModel::PrtModel(QObject *parent)
    : QObject(parent)
{
    boardManager_.init();

    connect(&boardManager_, &strata::BoardManager::boardReady, this, &PrtModel::boardReadyHandler);
    connect(&boardManager_, &strata::BoardManager::boardDisconnected, this, &PrtModel::boardDisconnectedHandler);

    connect(&downloadManager_, &strata::DownloadManager::groupDownloadFinished, this, &PrtModel::downloadFinishedHandler);
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

void PrtModel::downloadFinishedHandler(QString groupId, QString errorString)
{
    if (groupId != downloadJobId_) {
        return;
    }

    qCDebug(logCategoryPrt) << groupId << errorString;

    //TODO start flashing loop

    //TODO once all boards are flashed, clean up the files
    bootloaderFile_->deleteLater();
    firmwareFile_->deleteLater();
    downloadJobId_.clear();
}

void PrtModel::downloadBinaries(
        const QString &bootloaderUrl,
        const QString &bootloaderChecksum,
        const QString &firmwareUrl,
        const QString &firmwareChecksum)
{
    if (downloadJobId_.isEmpty() == false) {
        return;
    }

    //we need to open file so it is created on the disk and DownloadManager can use it
    bootloaderFile_ = new QTemporaryFile(QDir(QDir::tempPath()).filePath("prt-bootloader-XXXXXX.bin"), this);
    bootloaderFile_->open();
    bootloaderFile_->close();

    firmwareFile_ = new QTemporaryFile(QDir(QDir::tempPath()).filePath("prt-firmware-XXXXXX.bin"), this);
    firmwareFile_->open();
    firmwareFile_->close();

    QList<strata::DownloadManager::DownloadRequestItem> downloadRequestList;

    strata::DownloadManager::DownloadRequestItem bootloaderItem;
    bootloaderItem.url = bootloaderUrl;
    bootloaderItem.md5 = bootloaderChecksum;
    bootloaderItem.filePath = bootloaderFile_->fileName();
    downloadRequestList << bootloaderItem;

    strata::DownloadManager::DownloadRequestItem firmwareItem;
    firmwareItem.url = firmwareUrl;
    firmwareItem.md5 = firmwareChecksum;
    firmwareItem.filePath = firmwareFile_->fileName();
    downloadRequestList << firmwareItem;

    strata::DownloadManager::Settings settings;
    settings.oneFailsAllFail = true;
    settings.keepOriginalName = true;

    qCDebug(logCategoryPrt) << "download bootloader" << bootloaderItem.url.toString()
                            << "into" << bootloaderItem.filePath;

    qCDebug(logCategoryPrt) << "download firmware" << firmwareItem.url.toString()
                            << "into" << firmwareItem.filePath;

    downloadJobId_ = downloadManager_.download(downloadRequestList, settings);

    qCDebug(logCategoryPrt) << "downloadJobId" << downloadJobId_;
}
