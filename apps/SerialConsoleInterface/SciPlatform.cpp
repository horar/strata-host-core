#include "SciPlatform.h"
#include "logging/LoggingQtCategories.h"

#include <Mock/MockDeviceScanner.h>

#include <SGUtilsCpp.h>
#include <SGJsonFormatter.h>

#include <QJsonDocument>
#include <QStandardPaths>
#include <QDir>
#include <QSaveFile>

SciPlatform::SciPlatform(
        SciPlatformSettings *settings,
        strata::PlatformManager *platformManager,
        QObject *parent)
    : QObject(parent),
      settings_(settings)
{
    verboseName_ = "Unknown Board";
    status_ = PlatformStatus::Disconnected;
    platformManager_ = platformManager;

    mockDevice_ = new SciMockDevice(platformManager_);
    scrollbackModel_ = new SciScrollbackModel(this);
    commandHistoryModel_ = new SciCommandHistoryModel(this);
    filterSuggestionModel_ = new SciFilterSuggestionModel(this);
}

SciPlatform::~SciPlatform()
{
    mockDevice_->deleteLater();
    scrollbackModel_->deleteLater();
    commandHistoryModel_->deleteLater();
    filterSuggestionModel_->deleteLater();
}

QByteArray SciPlatform::deviceId()
{
    return deviceId_;
}

strata::device::Device::Type SciPlatform::deviceType()
{
    return deviceType_;
}

void SciPlatform::setDeviceType(const strata::device::Device::Type &type)
{
    if (deviceType_ != type) {
        deviceType_ = type;
        emit deviceTypeChanged();
    }
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
        mockDevice_->setMockDevice(nullptr);
        setStatus(PlatformStatus::Disconnected);
    } else {
        platform_ = platform;
        deviceId_ = platform_->deviceId();
        setDeviceType(platform_->deviceType());
        mockDevice_->mockSetDeviceId(deviceId_);
        if (platform_->deviceType() == strata::device::Device::Type::MockDevice) {
            auto scanner = platformManager_->getScanner(strata::device::Device::Type::MockDevice);
            auto mockScanner = std::dynamic_pointer_cast<strata::device::scanner::MockDeviceScanner>(scanner);
            if (mockScanner == nullptr) {
                qCCritical(logCategorySci) << "cannot get scanner for mock devices";
                return;
            }
            strata::device::DevicePtr device = mockScanner->getMockDevice(deviceId_);
            mockDevice_->setMockDevice(std::dynamic_pointer_cast<strata::device::MockDevice>(device));
        }

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

SciMockDevice* SciPlatform::mockDevice()
{
    return mockDevice_;
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

void SciPlatform::sendMessage(const QString &message, bool onlyValidJson)
{
    if (status_ != PlatformStatus::Ready
            && status_ != PlatformStatus::NotRecognized) {

        emit sendMessageResultReceived(SendMessageErrorType::NotConnectedError, QVariantMap());
        return;
    }

    if (onlyValidJson) {
        QJsonParseError parseError;
        QJsonDocument doc = QJsonDocument::fromJson(message.toUtf8(), &parseError);

        if (parseError.error != QJsonParseError::NoError) {
            QVariantMap data;
            data["offset"] = parseError.offset;
            data["message"] = parseError.errorString();

            emit sendMessageResultReceived(SendMessageErrorType::JsonError, data);
            return;
        }
    }

    //compact format as line break is end of input for serial library
    QString compactMsg = SGJsonFormatter::minifyJson(message);

    currentMessageId_ = platform_->sendMessage(compactMsg.toUtf8());
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

    flasherConnector_->flash(doBackup, strata::Flasher::FinalAction::PreservePlatformState);
    setProgramInProgress(true);

    return true;
}

QString SciPlatform::saveDeviceFirmware(QString filePath) {
    if (status_ != PlatformStatus::Ready) {
        QString errorString(QStringLiteral("platform not ready"));
        qCWarning(logCategorySci) << platform_ << errorString;
        return errorString;
    }

    if (flasherConnector_.isNull() == false) {
        QString errorString(QStringLiteral("flasherConnector already exists"));
        qCWarning(logCategorySci) << platform_ << errorString;
        return errorString;
    }

    if (filePath.isEmpty()) {
        QString errorString(QStringLiteral("no file name specified"));
        qCCritical(logCategorySci) << platform_ << errorString;
        return errorString;
    }

    QFileInfo fileInfo(filePath);
    if (fileInfo.isRelative()) {
        QString errorString(QStringLiteral("cannot use relative path for backup file"));
        qCCritical(logCategorySci) << platform_ << errorString;
        return errorString;
    }

    flasherConnector_ = new strata::FlasherConnector(platform_, filePath, this);

    connect(flasherConnector_, &strata::FlasherConnector::backupProgress, this, &SciPlatform::flasherBackupProgressHandler);
    connect(flasherConnector_, &strata::FlasherConnector::operationStateChanged, this, &SciPlatform::flasherOperationStateChangedHandler);
    connect(flasherConnector_, &strata::FlasherConnector::finished, this, &SciPlatform::flasherFinishedHandler);
    connect(flasherConnector_, &strata::FlasherConnector::devicePropertiesChanged, this, &SciPlatform::resetPropertiesFromDevice);

    flasherConnector_->backup(strata::Flasher::FinalAction::PreservePlatformState);
    setProgramInProgress(true);

    return QString();
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

void SciPlatform::messageFromDeviceHandler(strata::platform::PlatformMessage message)
{
    scrollbackModel_->append(message.raw(), false);
    filterSuggestionModel_->add(message.raw());
}

void SciPlatform::messageToDeviceHandler(QByteArray rawMessage, uint msgNumber, QString errorString)
{
    if (currentMessageId_ != msgNumber) {
        //message not sent by user manually
        if (errorString.isEmpty()) {
            scrollbackModel_->append(rawMessage, true);
        }

        return;
    }

    SendMessageErrorType errorType = SendMessageErrorType::NoError;
    QVariantMap result;

    if (errorString.isEmpty()) {
        commandHistoryModel_->add(SGJsonFormatter::minifyJson(rawMessage));
        settings_->setCommandHistory(verboseName_, commandHistoryModel()->getCommandList());
        scrollbackModel_->append(rawMessage, true);
    } else {
        errorType = SendMessageErrorType::PlatformError;
        result.insert("error_string", errorString);

        qCWarning(logCategorySci) << platform_ << "Error '" << errorString
            << "' occured while sending message '" << rawMessage << '\'';
    }

    emit sendMessageResultReceived(errorType, result);
}

void SciPlatform::deviceErrorHandler(strata::device::Device::ErrorCode errorCode, QString errorString)
{
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
