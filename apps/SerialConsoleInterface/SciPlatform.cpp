#include "SciPlatform.h"
#include "logging/LoggingQtCategories.h"

#include <SGUtilsCpp.h>
#include <SGJsonFormatter.h>

#include <QJsonDocument>
#include <QStandardPaths>
#include <QDir>
#include <QSaveFile>


SciPlatform::SciPlatform(
        SciPlatformSettings *settings,
        QObject *parent)
    : QObject(parent),
      settings_(settings)
{
    verboseName_ = "Unknown Board";
    status_ = PlatformStatus::Disconnected;

    scrollbackModel_ = new SciScrollbackModel(this);
    commandHistoryModel_ = new SciCommandHistoryModel(this);
    filterSuggestionModel_ = new SciFilterSuggestionModel(this);
}

SciPlatform::~SciPlatform()
{
    scrollbackModel_->deleteLater();
    commandHistoryModel_->deleteLater();
    filterSuggestionModel_->deleteLater();
}

QByteArray SciPlatform::deviceId()
{
    return deviceId_;
}

void SciPlatform::setPlatform(const strata::platform::PlatformPtr& platform)
{
    if (platform == nullptr) {
        if (status_ == PlatformStatus::Disconnected) {
             qCCritical(logCategorySci) << "platform is already disconnected";
             return;
        }

        disconnect(platform_.get(), nullptr, this, nullptr);
        platform_.reset();
        setStatus(PlatformStatus::Disconnected);
    } else {
        platform_ = platform;
        deviceId_ = platform_->deviceId();

        connect(platform_.get(), &strata::platform::Platform::messageReceived, this, &SciPlatform::messageFromDeviceHandler);
        connect(platform_.get(), &strata::platform::Platform::messageSent, this, &SciPlatform::messageToDeviceHandler);
        connect(platform_.get(), &strata::platform::Platform::deviceError, this, &SciPlatform::deviceErrorHandler);

        setStatus(PlatformStatus::Connected);
    }
}

QString SciPlatform::verboseName()
{
    return verboseName_;
}

void SciPlatform::setVerboseName(const QString &verboseName)
{
    if (verboseName_ != verboseName) {
        verboseName_ = verboseName;
        emit verboseNameChanged();
    }
}

QString SciPlatform::appVersion()
{
    return appVersion_;
}

void SciPlatform::setAppVersion(const QString &appVersion)
{
    if (appVersion_ != appVersion) {
        appVersion_ = appVersion;
        emit appVersionChanged();
    }
}

QString SciPlatform::bootloaderVersion()
{
    return bootloaderVersion_;
}

void SciPlatform::setBootloaderVersion(const QString &bootloaderVersion)
{
    if (bootloaderVersion_ != bootloaderVersion) {
        bootloaderVersion_ = bootloaderVersion;
        emit bootloaderVersionChanged();
    }
}

SciPlatform::PlatformStatus SciPlatform::status()
{
    return status_;
}

void SciPlatform::setStatus(SciPlatform::PlatformStatus status)
{
    if (status_ != status) {
        status_ = status;
        emit statusChanged();
    }
}

SciScrollbackModel *SciPlatform::scrollbackModel()
{
    return scrollbackModel_;
}

SciCommandHistoryModel *SciPlatform::commandHistoryModel()
{
    return commandHistoryModel_;
}

SciFilterSuggestionModel *SciPlatform::filterSuggestionModel()
{
    return filterSuggestionModel_;
}

QString SciPlatform::errorString()
{
    return errorString_;
}

void SciPlatform::setErrorString(const QString &errorString)
{
    if (errorString_ != errorString) {
        errorString_ = errorString;
        emit errorStringChanged();
    }
}

bool SciPlatform::programInProgress() const
{
    return programInProgress_;
}

QString SciPlatform::deviceName() const
{
    return deviceName_;
}

void SciPlatform::setDeviceName(const QString &deviceName)
{
    if (deviceName_ != deviceName) {
        deviceName_ = deviceName;
        emit deviceNameChanged();
    }
}

void SciPlatform::resetPropertiesFromDevice()
{
    if (platform_ == nullptr) {
        return;
    }

    QString verboseName = platform_->name();
    QString appVersion = platform_->applicationVer();
    QString bootloaderVersion = platform_->bootloaderVer();

    if (verboseName.isEmpty()) {
        if (appVersion.isEmpty() == false) {
            verboseName = "Application v" + appVersion;
        } else if (bootloaderVersion.isEmpty() == false) {
            verboseName = "Bootloader v" + bootloaderVersion;
        } else {
            verboseName = "Unknown Board";
        }
    }

    setVerboseName(verboseName);
    setAppVersion(appVersion);
    setBootloaderVersion(bootloaderVersion);
    setDeviceName(platform_->deviceName());
}

QVariantMap SciPlatform::sendMessage(const QString &message, bool onlyValidJson)
{
    QVariantMap retStatus;

    if (status_ != PlatformStatus::Ready
            && status_ != PlatformStatus::NotRecognized) {

        retStatus["error"] = "not_connected";
        return retStatus;
    }

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(message.toUtf8(), &parseError);
    bool isJsonValid = parseError.error == QJsonParseError::NoError;

    if (onlyValidJson) {
        if (isJsonValid == false) {
            retStatus["error"] = "json_error";
            retStatus["offset"] = parseError.offset;
            retStatus["message"] = parseError.errorString();
            return retStatus;
        }
    }

    //compact format as line break is end of input for serial library
    QString compactMsg = SGJsonFormatter::minifyJson(message);

    bool result = platform_->sendMessage(compactMsg.toUtf8());
    if (result) {
        commandHistoryModel_->add(compactMsg, isJsonValid);
        settings_->setCommandHistory(verboseName_, commandHistoryModel()->getCommandList());
        retStatus["error"] = "no_error";
    } else {
        retStatus["error"] = "send_error";
    }

    return retStatus;
}

bool SciPlatform::programDevice(QString filePath, bool doBackup)
{
    if (status_ != PlatformStatus::Ready
            && status_ != PlatformStatus::NotRecognized) {
        qCWarning(logCategorySci) << "platform not ready";
        return false;
    }

    if (flasherConnector_.isNull() == false) {
        qCWarning(logCategorySci) << "flasherConnector already exists";
        return false;
    }

    flasherConnector_ = new strata::FlasherConnector(platform_, filePath, this);

    connect(flasherConnector_, &strata::FlasherConnector::flashProgress, this, &SciPlatform::flasherProgramProgressHandler);
    connect(flasherConnector_, &strata::FlasherConnector::backupProgress, this, &SciPlatform::flasherBackupProgressHandler);
    connect(flasherConnector_, &strata::FlasherConnector::restoreProgress, this, &SciPlatform::flasherRestoreProgressHandler);
    connect(flasherConnector_, &strata::FlasherConnector::operationStateChanged, this, &SciPlatform::flasherOperationStateChangedHandler);
    connect(flasherConnector_, &strata::FlasherConnector::finished, this, &SciPlatform::flasherFinishedHandler);
    connect(flasherConnector_, &strata::FlasherConnector::devicePropertiesChanged, this, &SciPlatform::resetPropertiesFromDevice);

    flasherConnector_->flash(doBackup);
    setProgramInProgress(true);

    return true;
}

void SciPlatform::storeCommandHistory(const QStringList &list)
{
    settings_->setCommandHistory(verboseName_, list);
}

void SciPlatform::storeExportPath(const QString &exportPath)
{
    settings_->setExportPath(verboseName_, exportPath);
}

void SciPlatform::storeAutoExportPath(const QString &autoExportPath)
{
    settings_->setAutoExportPath(verboseName_, autoExportPath);
}

void SciPlatform::messageFromDeviceHandler(QByteArray deviceId, strata::platform::PlatformMessage message)
{
    Q_UNUSED(deviceId)
    scrollbackModel_->append(message.raw(), false);
    filterSuggestionModel_->add(message.raw());
}

void SciPlatform::messageToDeviceHandler(QByteArray deviceId, strata::platform::PlatformMessage message)
{
    Q_UNUSED(deviceId)
    scrollbackModel_->append(message.raw(), true);
}

void SciPlatform::deviceErrorHandler(QByteArray deviceId, strata::device::Device::ErrorCode errorCode, QString errorString)
{
    Q_UNUSED(deviceId)
    Q_UNUSED(errorCode)
    setErrorString(errorString);
}

void SciPlatform::flasherProgramProgressHandler(int chunk, int total)
{
    emit flasherProgramProgress(chunk, total);
}

void SciPlatform::flasherBackupProgressHandler(int chunk, int total)
{
    emit flasherBackupProgress(chunk, total);
}

void SciPlatform::flasherRestoreProgressHandler(int chunk, int total)
{
    emit flasherRestoreProgress(chunk, total);
}

void SciPlatform::flasherOperationStateChangedHandler(
        strata::FlasherConnector::Operation operation,
        strata::FlasherConnector::State state,
        QString errorString)
{
    emit flasherOperationStateChanged(operation, state, errorString);
}

void SciPlatform::flasherFinishedHandler(strata::FlasherConnector::Result result)
{
    flasherConnector_->disconnect();
    flasherConnector_->deleteLater();

    emit flasherFinished(result);

    setProgramInProgress(false);
}

void SciPlatform::setProgramInProgress(bool programInProgress)
{
    if (programInProgress_ != programInProgress) {
        programInProgress_ = programInProgress;
        emit programInProgressChanged();
    }
}
