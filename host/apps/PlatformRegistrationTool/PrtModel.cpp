#include "PrtModel.h"
#include "logging/LoggingQtCategories.h"
#include "DownloadManager.h"

#include <QDir>
#include <QSettings>

PrtModel::PrtModel(QObject *parent)
    : QObject(parent),
      downloadManager_(&networkManager_),
      authenticator_(&restClient_),
      opnListModel_(&restClient_)
{
    QSettings settings("prt-config.ini", QSettings::IniFormat);

    QUrl baseUrl = settings.value("cloud-service/url").toUrl();

    if (baseUrl.isValid() == false) {
        qCCritical(logCategoryPrt) << "cloud service url is not valid:" << baseUrl.toString();
    }

    if (baseUrl.scheme().isEmpty()) {
        qCCritical(logCategoryPrt) << "cloud service url does not have scheme:" << baseUrl.toString();
    }

    restClient_.init(baseUrl, &networkManager_, &authenticator_);

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

Authenticator* PrtModel::authenticator()
{
    return &authenticator_;
}

RestClient *PrtModel::restClient()
{
    return &restClient_;
}

OpnListModel *PrtModel::opnListModel()
{
    return &opnListModel_;
}

QString PrtModel::bootloaderFilepath()
{
    if(bootloaderFile_.isNull()) {
        return QString();
    }

    return bootloaderFile_->fileName();
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

void PrtModel::programDevice()
{
    //fake
//    QTimer::singleShot(2000, [this](){
//        emit flasherFinished(strata::FlasherConnector::Result::Success);
//    });


//    return;

    QString errorString;

    if (platformList_.isEmpty()) {
        errorString = "No platform connected";
    } else if (platformList_.length() > 1) {
        errorString = "More than one platform is connected";
    } else if (flasherConnector_.isNull() == false) {
        errorString = "Programming already in progress";
    } else if (firmwareFile_.isNull()) {
        errorString = "Firmware not downloaded";
    }

    if (errorString.isEmpty() == false) {
        qCCritical(logCategoryPrt) << errorString;
        emit flasherOperationStateChanged(
                    strata::FlasherConnector::Operation::Preparation,
                    strata::FlasherConnector::State::Failed,
                    errorString);

        emit flasherFinished(strata::FlasherConnector::Result::Unsuccess);
        return;
    }

    flasherConnector_ = new strata::FlasherConnector(platformList_.first(), firmwareFile_->fileName(), this);

    connect(flasherConnector_, &strata::FlasherConnector::operationStateChanged, this, &PrtModel::flasherOperationStateChanged);
    connect(flasherConnector_, &strata::FlasherConnector::flashProgress, this, &PrtModel::flasherProgress);
    connect(flasherConnector_, &strata::FlasherConnector::finished, this, &PrtModel::flasherFinishedHandler);

    flasherConnector_->flash(false);
}

void PrtModel::downloadBinaries(int platformIndex)
{
    QTimer::singleShot(2500, this, [this](){

        bool ok = false;//fakeDownloadBinaries(
//                    "/Users/zbh6nr/dev/strata firmware/with_bootloader/bootloader-release.bin",
//                    "/Users/zbh6nr/dev/strata firmware/with_bootloader/water-heater-release.bin");

//        qDebug() << "bootloader" << bootloaderFile_->fileName();
//        qDebug() << "firmware" << firmwareFile_->fileName();

        if (ok == false) {
            emit downloadFirmwareFinished("Fake download failed");
            //emit downloadFirmwareFinished("Download failed");
        } else {
            emit downloadFirmwareFinished("");
        }
    });
}

void PrtModel::registerPlatform()
{
    //fake for now
    QTimer::singleShot(4000, [this](){
        emit registerPlatformFinished("fake registration failed");
    });
}

void PrtModel::clearBinaries()
{
    if (bootloaderFile_.isNull() == false) {
        bootloaderFile_->deleteLater();
        emit bootloaderFilepathChanged();
    }

    if (firmwareFile_.isNull() == false) {
        firmwareFile_->deleteLater();
    }
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

    downloadFirmwareFinished(errorString);

    downloadJobId_.clear();
}

bool PrtModel::fakeDownloadBinaries(const QString &bootloaderUrl, const QString &firmwareUrl)
{
    //bootloader
    QFile bootloaderFile(bootloaderUrl);
    if (bootloaderFile.open(QIODevice::ReadOnly) == false) {
        return false;
    }
    QByteArray data = bootloaderFile.readAll();

    bootloaderFile_ = new QTemporaryFile(QDir(QDir::tempPath()).filePath("prt-bootloader-XXXXXX.bin"), this);
    bootloaderFile_->open();
    bootloaderFile_->write(data);
    bootloaderFile_->close();
    bootloaderFile.close();

    emit bootloaderFilepathChanged();

    //firmware
    QFile firmwareFile(firmwareUrl);
    if (firmwareFile.open(QIODevice::ReadOnly) == false) {
        return false;
    }
    data = firmwareFile.readAll();

    firmwareFile_ = new QTemporaryFile(QDir(QDir::tempPath()).filePath("prt-firmware-XXXXXX.bin"), this);
    firmwareFile_->open();
    firmwareFile_->write(data);
    firmwareFile_->close();
    firmwareFile.close();

    return true;
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

    emit bootloaderFilepathChanged();

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
