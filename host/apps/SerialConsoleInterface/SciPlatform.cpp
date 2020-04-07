#include "SciPlatform.h"
#include <DeviceProperties.h>
#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
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
}

SciPlatform::~SciPlatform()
{
    scrollbackModel_->deleteLater();
    commandHistoryModel_->deleteLater();
}

int SciPlatform::deviceId()
{
    return deviceId_;
}

void SciPlatform::setDevice(strata::SerialDevicePtr device)
{
    if (device == nullptr) {
        device_->disconnect();
        device_.reset();
        setStatus(PlatformStatus::Disconnected);
    } else {
        device_ = device;
        deviceId_ = device_->deviceId();

        connect(device_.get(), &strata::SerialDevice::msgFromDevice, this, &SciPlatform::messageFromDeviceHandler);
        connect(device_.get(), &strata::SerialDevice::messageSent, this, &SciPlatform::messageToDeviceHandler);
        connect(device_.get(), &strata::SerialDevice::serialDeviceError, this, &SciPlatform::deviceErrorHandler);

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

void SciPlatform::resetPropertiesFromDevice()
{
    if (device_ == nullptr) {
        return;
    }

    QString verboseName = device_->property(strata::DeviceProperties::verboseName);
    QString appVersion = device_->property(strata::DeviceProperties::applicationVer);
    QString bootloaderVersion = device_->property(strata::DeviceProperties::bootloaderVer);

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
}

bool SciPlatform::sendMessage(const QByteArray &message)
{
    if (status_ != PlatformStatus::Ready
            && status_ != PlatformStatus::NotRecognized) {

        setErrorString("Platform not connected");
        return false;
    }

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(message, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        QString error = QString("JSON error at position %1 - %2")
                .arg(parseError.offset)
                .arg(parseError.errorString());

        setErrorString(error);
        return false;
    }

    QByteArray compactMessage = doc.toJson(QJsonDocument::Compact);

    bool result = device_->sendMessage(compactMessage);
    if (result) {
        commandHistoryModel_->add(compactMessage);
        settings_->setCommandHistory(verboseName_, commandHistoryModel()->getCommandList());
    }

    return result;
}

bool SciPlatform::exportScrollback(QString filePath) const
{
    QSaveFile file(filePath);
    bool ret = file.open(QIODevice::WriteOnly | QIODevice::Text);
    if (ret == false) {
        qCCritical(logCategorySci) << "cannot open file" << filePath << file.errorString();
        return false;
    }

    QTextStream out(&file);

    out << scrollbackModel_->getTextForExport();

    return file.commit();
}

void SciPlatform::removeCommandFromHistoryAt(int index)
{
    bool isRemoved = commandHistoryModel_->removeAt(index);
    if (isRemoved) {
        settings_->setCommandHistory(verboseName_, commandHistoryModel()->getCommandList());
    }
}

void SciPlatform::messageFromDeviceHandler(QByteArray message)
{
    scrollbackModel_->append(message, SciScrollbackModel::MessageType::Response);
}

void SciPlatform::messageToDeviceHandler(QByteArray message)
{
    scrollbackModel_->append(message, SciScrollbackModel::MessageType::Request);
}

void SciPlatform::deviceErrorHandler(int errorCode, QString message)
{
    Q_UNUSED(errorCode);
    setErrorString(message);
}
