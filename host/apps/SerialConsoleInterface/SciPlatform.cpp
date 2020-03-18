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

QVariantMap SciPlatform::sendMessage(const QByteArray &message)
{
    QVariantMap errorMap;
    errorMap["errorString"] = "";
    errorMap["offset"] = -1;

    if (status_ != PlatformStatus::Ready
            && status_ != PlatformStatus::NotRecognized) {

        errorMap["errorString"] = "platform not connected";
        return errorMap;
    }

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(message, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        qCWarning(logCategorySci) << "cannot parse JSON"
                   << "offset=" << parseError.offset
                   << "error=" << parseError.error
                   << parseError.errorString();

        errorMap["errorString"] = parseError.errorString();
        errorMap["offset"] = parseError.offset;
        return errorMap;
    }

    QByteArray compactMessage = doc.toJson(QJsonDocument::Compact);

    scrollbackModel_->append(compactMessage, SciScrollbackModel::MessageType::Request);
    commandHistoryModel_->add(compactMessage);
    settings_->setCommandHistory(verboseName_, commandHistoryModel()->getCommandList());

    device_->sendMessage(compactMessage);

    return errorMap;
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

void SciPlatform::messageFromDeviceHandler(QByteArray message)
{
    scrollbackModel_->append(message, SciScrollbackModel::MessageType::Response);
}

void SciPlatform::deviceErrorHandler(QString message)
{
    Q_UNUSED(message)

}
