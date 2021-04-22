#include "PrtModel.h"
#include "logging/LoggingQtCategories.h"
#include <SGUtilsCpp.h>

#include <Operations/StartBootloader.h>
#include <Operations/StartApplication.h>
#include <Operations/SetPlatformId.h>
#include <Operations/SetAssistedPlatformId.h>
#include <PlatformOperationsStatus.h>

#include <QDir>
#include <QSettings>
#include <QCoreApplication>
#include <QJsonDocument>
#include <QJsonObject>


PrtModel::PrtModel(QObject *parent)
    : QObject(parent),
      platformManager_(true, true, true),
      downloadManager_(&networkManager_),
      authenticator_(&restClient_)
{
    QString configFilePath = resolveConfigFilePath();

    qCDebug(logCategoryPrt) << "config file:" << configFilePath;

    QSettings settings(configFilePath, QSettings::IniFormat);

    cloudServiceUrl_ = settings.value("cloud-service/url").toUrl();
    serverType_ = settings.value("cloud-service/server").toString();

    if (cloudServiceUrl_.isValid() == false) {
        qCCritical(logCategoryPrt) << "cloud service url is not valid:" << cloudServiceUrl_.toString();
    }

    if (cloudServiceUrl_.scheme().isEmpty()) {
        qCCritical(logCategoryPrt) << "cloud service url does not have scheme:" << cloudServiceUrl_.toString();
    }

    restClient_.init(cloudServiceUrl_, &networkManager_, &authenticator_);

    platformManager_.init(strata::device::Device::Type::SerialDevice);

    connect(&platformManager_, &strata::PlatformManager::platformRecognized, this, &PrtModel::deviceInfoChangeHandler);
    connect(&platformManager_, &strata::PlatformManager::platformAboutToClose, this, &PrtModel::deviceDisconnectedHandler);

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
        return QString();
    }

    return platformList_.first()->applicationVer();
}

QString PrtModel::deviceFirmwareVerboseName() const
{
    if (platformList_.isEmpty()) {
        return QString();
    }

    return platformList_.first()->name();
}

QString PrtModel::devicePlatformId() const
{
    if (platformList_.isEmpty()) {
        return QString();
    }

    return platformList_.first()->platformId();
}

QString PrtModel::deviceClassId() const
{
    if (platformList_.isEmpty()) {
        return QString();
    }

    return platformList_.first()->classId();
}

QString PrtModel::deviceControllerPlatformId() const
{
    if (platformList_.isEmpty()) {
        return QString();
    }

    return platformList_.first()->controllerPlatformId();
}

QString PrtModel::deviceControllerClassId() const
{
    if (platformList_.isEmpty()) {
        return QString();
    }

    return platformList_.first()->controllerClassId();
}

bool PrtModel::isAssistedDeviceConnected() const
{
    if (platformList_.isEmpty()) {
        return false;
    }

    return platformList_.first()->isControllerConnectedToPlatform();
}

void PrtModel::programDevice()
{
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

void PrtModel::downloadBinaries(
        const QString bootloaderUrl,
        const QString bootloaderMd5,
        const QString firmwareUrl,
        const QString firmwareMd5)
{

    //use this to fake it
    QTimer::singleShot(2500, this, [this, bootloaderUrl, firmwareUrl](){
        bool ok = fakeDownloadBinaries(
                    bootloaderUrl.isEmpty() ? "" : "/Users/zbh6nr/dev/strata firmware/with_assisted/bootloader-release-erase.bin",
                    firmwareUrl.isEmpty() ? "" : "/Users/zbh6nr/dev/strata firmware/with_assisted/str-level-shifters-gevb-v002.bin");

        if (ok == false) {
            emit downloadFirmwareFinished("Fake download failed");
        } else {
            if (bootloaderFile_.isNull() == false) {
                qDebug() << "bootloader" << bootloaderFile_->fileName();
            }

            if (firmwareFile_.isNull() == false) {
                qDebug() << "firmware" << firmwareFile_->fileName();
            }

            emit downloadFirmwareFinished("");
        }
    });

    return;

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

    if (bootloaderUrl.isEmpty() == false) {
        strata::DownloadManager::DownloadRequestItem bootloaderItem;
        bootloaderItem.url = cloudServiceUrl_.resolved(bootloaderUrl);
        bootloaderItem.md5 = bootloaderMd5;
        bootloaderItem.filePath = bootloaderFile_->fileName();
        downloadRequestList << bootloaderItem;

        qCDebug(logCategoryPrt) << "download bootloader" << bootloaderItem.url.toString()
                                << "into" << bootloaderItem.filePath;
    }

    if (firmwareUrl.isEmpty() == false) {
        strata::DownloadManager::DownloadRequestItem firmwareItem;
        firmwareItem.url = cloudServiceUrl_.resolved(firmwareUrl);
        firmwareItem.md5 = firmwareMd5;
        firmwareItem.filePath = firmwareFile_->fileName();
        downloadRequestList << firmwareItem;

        qCDebug(logCategoryPrt) << "download firmware" << firmwareItem.url.toString()
                                << "into" << firmwareItem.filePath;
    }

    if (downloadRequestList.isEmpty()) {
        qCWarning(logCategoryPrt) << "nothing to download";
        return;
    }

    strata::DownloadManager::Settings settings;
    settings.oneFailsAllFail = true;
    settings.keepOriginalName = true;
    settings.removeCorruptedFile = false;

    downloadJobId_ = downloadManager_.download(downloadRequestList, settings);

    qCDebug(logCategoryPrt) << "downloadJobId" << downloadJobId_;
}

void PrtModel::notifyServiceAboutRegistration(
        const QString &classId,
        const QString &platformId)
{
    qCDebug(logCategoryPrtAuth) << "classId" << classId;
    qCDebug(logCategoryPrtAuth) << "platformId" << platformId;

    QJsonDocument doc;
    QJsonObject data;


    data.insert("platform_id", platformId);
    data.insert("class_id", classId );
    doc.setObject(data);

    Deferred *deferred = restClient_.post(
                QUrl("platform_register"),
                QVariantMap(),
                doc.toJson(QJsonDocument::Compact));


    connect(deferred, &Deferred::finishedSuccessfully, [this] (int status, QByteArray data) {
        Q_UNUSED(status)

        qCDebug(logCategoryPrtAuth) << "reply data" << data;

        QJsonParseError parseError;
        QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);

        if (parseError.error != QJsonParseError::NoError) {
            qCCritical(logCategoryPrtAuth) << "failed, cannot parse reply" << parseError.errorString();
            qCCritical(logCategoryPrtAuth) << "data:"<< data;

            emit notifyServiceFinished(-1, "invalid reply");
            return;
        }

        int boardCount = doc.object().value("count").toInt(-1);
        if (boardCount <= 0) {
            qCCritical(logCategoryPrtAuth) << "process failed";
            emit notifyServiceFinished(-1, "invalid reply");
            return;
        }

        emit notifyServiceFinished(boardCount, "");
    });

    connect(deferred, &Deferred::finishedWithError, [this] (int status, QString errorString) {
        qCCritical(logCategoryPrtAuth)
                << "failed, "
                << "status=" << status
                << "errorString=" << errorString;

        emit notifyServiceFinished(-1, errorString);
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

void PrtModel::abortDownload()
{
    downloadManager_.abortAll(downloadJobId_);
}

void PrtModel::setPlatformId(
        const QString &classId,
        const QString &platformId,
        int boardCount)
{
    using strata::platform::operation::SetPlatformId;
    using strata::platform::operation::Result;

    if (platformList_.isEmpty()) {
        QString errorString = "No platform connected";
        qCCritical(logCategoryPrt) << errorString;
        emit setPlatformIdFinished(errorString);
        return;
    }

    strata::platform::command::CmdSetPlatformIdData data;
    data.classId = classId;
    data.platformId = platformId;
    data.boardCount = boardCount;

    SetPlatformId *operation = new SetPlatformId(
                platformList_.first(),
                data);

    connect(operation, &SetPlatformId::finished, [this, operation](Result result, int status, QString errorString) {

        if (result != Result::Success) {
            emit setPlatformIdFinished(errorString);
        } else if (status == strata::platform::operation::SET_PLATFORM_ID_FAILED) {
            emit setPlatformIdFinished("Platform refused registration");
        } else if (status == strata::platform::operation::PLATFORM_ID_ALREADY_SET) {
            emit setPlatformIdFinished("Platform has already been registered");
        } else {
            emit setPlatformIdFinished("");
        }

        operation->deleteLater();
    });

    operation->run();
}

void PrtModel::setAssistedPlatformId(const QVariantMap &data)
{
    using strata::platform::operation::SetAssistedPlatformId;
    using strata::platform::operation::Result;

    if (platformList_.isEmpty()) {
        QString errorString = "No platform connected";
        qCCritical(logCategoryPrt) << errorString;
        emit setAssistedPlatformIdFinished(errorString);
        return;
    }

    SetAssistedPlatformId *operation = new SetAssistedPlatformId(platformList_.first());

    if (data.contains("class_id") && data.contains("platform_id") && data.contains("board_count")) {
        strata::platform::command::CmdSetPlatformIdData baseData;
        baseData.classId = data.value("class_id").toString();
        baseData.platformId = data.value("platform_id").toString();
        baseData.boardCount = data.value("board_count").toInt();
        operation->setBaseData(baseData);
    }

    if (data.contains("controller_class_id") && data.contains("controller_platform_id") && data.contains("controller_board_count")) {
        strata::platform::command::CmdSetPlatformIdData controllerData;
        controllerData.classId = data.value("controller_class_id").toString();
        controllerData.platformId = data.value("controller_platform_id").toString();
        controllerData.boardCount = data.value("controller_board_count").toInt();
        operation->setControllerData(controllerData);
    }

    if (data.contains("fw_class_id")) {
        operation->setFwClassId(data.value("fw_class_id").toString());
    }

    connect(operation, &SetAssistedPlatformId::finished, [this, operation](Result result, int status, QString errorString) {
        if (status == strata::platform::operation::SET_PLATFORM_ID_FAILED) {
            emit setAssistedPlatformIdFinished("failed");
        } else if (status == strata::platform::operation::PLATFORM_ID_ALREADY_SET) {
            emit setAssistedPlatformIdFinished("already_initialized");
        } else if(status == strata::platform::operation::BOARD_NOT_CONNECTED_TO_CONTROLLER) {
            emit setAssistedPlatformIdFinished("device_not_connected");
        } else if (result != Result::Success) {
            emit setAssistedPlatformIdFinished(errorString);
        } else{
            emit setAssistedPlatformIdFinished("ok");
        }

        operation->deleteLater();
    });

    operation->run();
}

void PrtModel::startBootloader()
{
    using strata::platform::operation::StartBootloader;
    using strata::platform::operation::Result;

    if (platformList_.isEmpty()) {
        QString errorString = "No platform connected";
        qCCritical(logCategoryPrt) << errorString;
        emit startBootloaderFinished(errorString);
        return;
    }

    StartBootloader *operation = new StartBootloader(platformList_.first());

    connect(operation, &StartBootloader::finished, [this, operation](Result result, int status, QString errorString) {
        if (errorString.isEmpty() == false ) {
            qCCritical(logCategoryPrt) << "start bootloader failed" << static_cast<int>(result) << errorString << status;
        }

        emit startBootloaderFinished(errorString);

        operation->deleteLater();
    });

    operation->run();
}

void PrtModel::startApplication()
{
    using strata::platform::operation::StartApplication;
    using strata::platform::operation::Result;

    if (platformList_.isEmpty()) {
        QString errorString = "No platform connected";
        qCCritical(logCategoryPrt) << errorString;
        emit startApplicationFinished(errorString);
        return;
    }

    StartApplication *operation = new StartApplication(platformList_.first());

    connect(operation, &StartApplication::finished, [this, operation](Result result, int status, QString errorString) {
        if (errorString.isEmpty() == false ) {
            qCCritical(logCategoryPrt) << "start bootloader failed" << static_cast<int>(result) << errorString << status;
        }

        emit startApplicationFinished(errorString);

        operation->deleteLater();
    });

    operation->run();
}

void PrtModel::deviceInfoChangeHandler(const QByteArray& deviceId, bool recognized)
{
    Q_UNUSED(recognized)

    strata::platform::PlatformPtr platform = platformManager_.getPlatform(deviceId);

    if (platformList_.indexOf(platform) < 0) {
        //new platform connected
        platformList_.append(platform);

        emit deviceCountChanged();
    } else {
        emit deviceInfoChanged(deviceId);
    }
}

void PrtModel::deviceDisconnectedHandler(const QByteArray& deviceId)
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

    emit downloadFirmwareFinished(errorString);

    downloadJobId_.clear();
}


bool PrtModel::fakeDownloadBinaries(const QString &bootloaderUrl, const QString &firmwareUrl)
{
    //bootloader
    if (bootloaderUrl.isEmpty() == false) {
        QFile bootloaderFile(bootloaderUrl);
        if (bootloaderFile.open(QIODevice::ReadOnly) == false) {
            qCCritical(logCategoryPrt()) << "cannot open bootloader file";
            return false;
        }
        QByteArray data = bootloaderFile.readAll();

        bootloaderFile_ = new QTemporaryFile(QDir(QDir::tempPath()).filePath("prt-bootloader-XXXXXX.bin"), this);
        bootloaderFile_->open();
        bootloaderFile_->write(data);
        bootloaderFile_->close();
        bootloaderFile.close();

        emit bootloaderFilepathChanged();
    }

    //firmware
    if (firmwareUrl.isEmpty() == false) {
        QFile firmwareFile(firmwareUrl);
        if (firmwareFile.open(QIODevice::ReadOnly) == false) {
            qCCritical(logCategoryPrt()) << "cannot open firmware file";
            return false;
        }
        QByteArray data = firmwareFile.readAll();

        firmwareFile_ = new QTemporaryFile(QDir(QDir::tempPath()).filePath("prt-firmware-XXXXXX.bin"), this);
        firmwareFile_->open();
        firmwareFile_->write(data);
        firmwareFile_->close();
        firmwareFile.close();
    }

    return true;
}

QString PrtModel::resolveConfigFilePath()
{
    QDir applicationDir(QCoreApplication::applicationDirPath());

#ifdef Q_OS_MACOS
    applicationDir.cdUp();
    applicationDir.cdUp();
    applicationDir.cdUp();
#endif

    return applicationDir.filePath("prt-config.ini");
}

QString PrtModel::serverType() const
{
    return serverType_;
}

bool PrtModel::debugBuild() const
{
#ifdef NDEBUG
    return false;
#else
    return true;
#endif
}
