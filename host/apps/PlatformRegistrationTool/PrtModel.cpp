#include "PrtModel.h"
#include "logging/LoggingQtCategories.h"
#include <SGUtilsCpp.h>

#include <QDir>
#include <QSettings>
#include <QCoreApplication>
#include <QJsonDocument>
#include <QJsonObject>

PrtModel::PrtModel(QObject *parent)
    : QObject(parent),
      downloadManager_(&networkManager_),
      authenticator_(&restClient_)
{
    QString configFilePath = resolveConfigFilePath();

    qCDebug(logCategoryPrt) << "config file:" << configFilePath;

    QSettings settings(configFilePath, QSettings::IniFormat);

    cloudServiceUrl_ = settings.value("cloud-service/url").toUrl();

    if (cloudServiceUrl_.isValid() == false) {
        qCCritical(logCategoryPrt) << "cloud service url is not valid:" << cloudServiceUrl_.toString();
    }

    if (cloudServiceUrl_.scheme().isEmpty()) {
        qCCritical(logCategoryPrt) << "cloud service url does not have scheme:" << cloudServiceUrl_.toString();
    }

    restClient_.init(cloudServiceUrl_, &networkManager_, &authenticator_);

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

//    //use this to fake it
//    QTimer::singleShot(2500, this, [this](){
//        bool ok = fakeDownloadBinaries(
//                    "/Users/martin/dev/strata firmware/with_bootloader/bootloader-release.bin",
//                    "/Users/martin/dev/strata firmware/with_bootloader/water-heater-release.bin");

//        qDebug() << "bootloader" << bootloaderFile_->fileName();
//        qDebug() << "firmware" << firmwareFile_->fileName();

//        if (ok == false) {
//            emit downloadFirmwareFinished("Fake download failed");
//        } else {
//            emit downloadFirmwareFinished("");
//        }
//    });

//    return;

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
    bootloaderItem.url = cloudServiceUrl_.resolved(bootloaderUrl);
    bootloaderItem.md5 = bootloaderMd5;
    bootloaderItem.filePath = bootloaderFile_->fileName();
    downloadRequestList << bootloaderItem;

    strata::DownloadManager::DownloadRequestItem firmwareItem;
    firmwareItem.url = cloudServiceUrl_.resolved(firmwareUrl);
    firmwareItem.md5 = firmwareMd5;
    firmwareItem.filePath = firmwareFile_->fileName();
    downloadRequestList << firmwareItem;

    strata::DownloadManager::Settings settings;
    settings.oneFailsAllFail = true;
    settings.keepOriginalName = true;
    settings.removeCorruptedFile = false;

    qCDebug(logCategoryPrt) << "download bootloader" << bootloaderItem.url.toString()
                            << "into" << bootloaderItem.filePath;

    qCDebug(logCategoryPrt) << "download firmware" << firmwareItem.url.toString()
                            << "into" << firmwareItem.filePath;

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

void PrtModel::requestBootloaderUrl()
{
    //TODO finish this method once bootloader endpoint is ready

    QTimer::singleShot(1000, [this](){
        emit bootloaderUrlRequestFinished("fake-bootloader-url","", "");
    });
}

void PrtModel::writeRegistrationData(
        const QString &classId,
        const QString &platfromId,
        int boardCount)
{
    QString errorString;
    if (platformList_.isEmpty()) {
        errorString = "No platform connected";
    }

    if (errorString.isEmpty() == false) {
        qCCritical(logCategoryPrt) << errorString;

        emit writeRegistrationDataFinished(errorString);
        return;
    }

    QJsonDocument doc;
    QJsonObject data;
    QJsonObject payload;
    payload.insert("class_id", classId);
    payload.insert("platform_id", platfromId);
    payload.insert("board_count", boardCount);

    data.insert("cmd", QSTR_SET_PLATFORM_ID);
    data.insert("payload", payload);

    doc.setObject(data);

    connect(platformList_.first().get(), &strata::device::Device::msgFromDevice, this, &PrtModel::messageFromDeviceHandler);

    QByteArray message = doc.toJson(QJsonDocument::Compact);
    qCDebug(logCategoryPrtAuth) << message;
    platformList_.first()->sendMessage(message);
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

void PrtModel::messageFromDeviceHandler(QByteArray message)
{
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(message, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        qCCritical(logCategoryPrtAuth) << "cannot parse message" << parseError.errorString();
        qCCritical(logCategoryPrtAuth) << "message:"<< message;
        return;
    }

    if (doc.object().contains("ack")
            && doc.object().value("ack").toString() == QSTR_SET_PLATFORM_ID)
    {
        QJsonObject payload = doc.object().value("payload").toObject();
        if(payload.isEmpty()) {
            finishRegistrationCommand("invalid response");
            return;
        }

        if (payload.value("return_value").toBool(false) == false) {
            finishRegistrationCommand("request not accepted by device");
            return;
        }
    } else if (doc.object().contains("notification")) {
        QJsonObject notification = doc.object().value("notification").toObject();

        if (notification.contains("value")
                && notification.value("value").toString() == QSTR_SET_PLATFORM_ID)
        {
            QJsonObject payload = notification.value("payload").toObject();
            if (payload.isEmpty()) {
                finishRegistrationCommand("invalid response");
                return;
            }

            QString status = payload.value("status").toString();
            if (status == "OK") {
                finishRegistrationCommand("");
            } else if (status == "failed!") {
                finishRegistrationCommand("failed to write data");
            } else if (status == "already_initialized") {
                finishRegistrationCommand("board has already been registered");
            } else {
                finishRegistrationCommand("invalid response");
            }
        }
    }
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

void PrtModel::finishRegistrationCommand(QString errorString)
{
    if (errorString.isEmpty() == false) {
        qCCritical(logCategoryPrt) << "set_platform_id failed:" << errorString;
    }

    disconnect(platformList_.first().get(), &strata::device::Device::msgFromDevice, this, nullptr);

    emit writeRegistrationDataFinished(errorString);
}
