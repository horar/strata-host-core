#pragma once

#include "SciScrollbackModel.h"
#include "SciCommandHistoryModel.h"
#include "SciFilterSuggestionModel.h"
#include "SciPlatformSettings.h"

#include <PlatformManager.h>
#include <FlasherConnector.h>
#include <Mock/MockDevice.h>
#include <QObject>
#include <QPointer>


class SciPlatform: public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(SciPlatform)

    Q_PROPERTY(QString deviceId READ deviceId CONSTANT)
    Q_PROPERTY(QString verboseName READ verboseName NOTIFY verboseNameChanged)
    Q_PROPERTY(QString appVersion READ appVersion NOTIFY appVersionChanged)
    Q_PROPERTY(QString bootloaderVersion READ bootloaderVersion NOTIFY bootloaderVersionChanged)
    Q_PROPERTY(QString deviceName READ deviceName NOTIFY deviceNameChanged)
    Q_PROPERTY(PlatformStatus status READ status NOTIFY statusChanged)
    Q_PROPERTY(strata::device::MockDevice* mockDevice READ mockDevice NOTIFY mockDeviceChanged)
    Q_PROPERTY(SciScrollbackModel* scrollbackModel READ scrollbackModel CONSTANT)
    Q_PROPERTY(SciCommandHistoryModel* commandHistoryModel READ commandHistoryModel CONSTANT)
    Q_PROPERTY(SciFilterSuggestionModel* filterSuggestionModel READ filterSuggestionModel CONSTANT)
    Q_PROPERTY(QString errorString READ errorString WRITE setErrorString NOTIFY errorStringChanged)
    Q_PROPERTY(bool programInProgress READ programInProgress NOTIFY programInProgressChanged)

public:
    SciPlatform(SciPlatformSettings *settings, QObject *parent = nullptr);

    virtual ~SciPlatform();

    enum PlatformStatus {
        Disconnected,
        Connected,
        Ready,
        NotRecognized,
    };
    Q_ENUM(PlatformStatus)

    QByteArray deviceId();
    void setPlatform(const strata::platform::PlatformPtr& platform);
    QString verboseName();
    void setVerboseName(const QString &verboseName);
    QString appVersion();
    void setAppVersion(const QString &appVersion);
    QString bootloaderVersion();
    void setBootloaderVersion(const QString &bootloaderVersion);
    SciPlatform::PlatformStatus status();
    void setStatus(SciPlatform::PlatformStatus status);
    strata::device::MockDevice* mockDevice() const;
    void setMockDevice(const strata::device::MockDevicePtr& mockDevice);
    SciScrollbackModel* scrollbackModel();
    SciCommandHistoryModel* commandHistoryModel();
    SciFilterSuggestionModel* filterSuggestionModel();
    QString errorString();
    void setErrorString(const QString &errorString);
    bool programInProgress() const;
    QString deviceName() const;
    void setDeviceName(const QString &deviceName);

    void resetPropertiesFromDevice();
    Q_INVOKABLE QVariantMap sendMessage(const QString &message, bool onlyValidJson);
    Q_INVOKABLE bool programDevice(QString filePath, bool doBackup=true);

    //settings handlers
    void storeCommandHistory(const QStringList &list);
    void storeExportPath(const QString &exportPath);
    void storeAutoExportPath(const QString &autoExportPath);

signals:
    void verboseNameChanged();
    void appVersionChanged();
    void bootloaderVersionChanged();
    void statusChanged();
    void errorStringChanged();
    void programInProgressChanged();
    void deviceNameChanged();
    void mockDeviceChanged();
    void flasherProgramProgress(int chunk, int total);
    void flasherBackupProgress(int chunk, int total);
    void flasherRestoreProgress(int chunk, int total);
    void flasherOperationStateChanged(
            strata::FlasherConnector::Operation operation,
            strata::FlasherConnector::State state,
            QString errorString);

    void flasherFinished(strata::FlasherConnector::Result result);


private slots:
    void messageFromDeviceHandler(QByteArray deviceId, strata::platform::PlatformMessage message);
    void messageToDeviceHandler(QByteArray deviceId, strata::platform::PlatformMessage message);
    void deviceErrorHandler(QByteArray deviceId, strata::device::Device::ErrorCode errorCode, QString errorString);
    void flasherProgramProgressHandler(int chunk, int total);
    void flasherBackupProgressHandler(int chunk, int total);
    void flasherRestoreProgressHandler(int chunk, int total);

    void flasherOperationStateChangedHandler(
            strata::FlasherConnector::Operation operation,
            strata::FlasherConnector::State state,
            QString errorString);

    void flasherFinishedHandler(strata::FlasherConnector::Result result);

private:
    strata::platform::PlatformPtr platform_;
    strata::device::MockDevicePtr mockDevice_;
    QByteArray deviceId_;
    QString verboseName_;
    QString appVersion_;
    QString bootloaderVersion_;
    PlatformStatus status_;
    QString errorString_;
    bool programInProgress_ = false;
    QString deviceName_;

    SciScrollbackModel *scrollbackModel_;
    SciCommandHistoryModel *commandHistoryModel_;
    SciPlatformSettings *settings_;
    SciFilterSuggestionModel *filterSuggestionModel_;
    QPointer<strata::FlasherConnector> flasherConnector_;

    void setProgramInProgress(bool programInProgress);
};
