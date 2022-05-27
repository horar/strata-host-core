/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include "SciScrollbackModel.h"
#include "SciCommandHistoryModel.h"
#include "SciFilterSuggestionModel.h"
#include "SciPlatformSettings.h"
#include "SciMockDevice.h"
#include "SciFilterScrollbackModel.h"
#include "SciSearchScrollbackModel.h"
#include "SciMessageQueueModel.h"
#include "SciPlatformValidation.h"
#include "SciPlatformTestModel.h"
#include "SciPlatformTestMessageModel.h"

#include <PlatformManager.h>
#include <FlasherConnector.h>
#include <Mock/MockDevice.h>
#include <QObject>
#include <QPointer>
#include <QJsonParseError>
#include <chrono>


class SciPlatform: public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(SciPlatform)

    Q_PROPERTY(QString deviceId READ deviceId CONSTANT)
    Q_PROPERTY(strata::device::Device::Type deviceType READ deviceType NOTIFY deviceTypeChanged)
    Q_PROPERTY(QString verboseName READ verboseName NOTIFY verboseNameChanged)
    Q_PROPERTY(QString appVersion READ appVersion NOTIFY appVersionChanged)
    Q_PROPERTY(QString bootloaderVersion READ bootloaderVersion NOTIFY bootloaderVersionChanged)
    Q_PROPERTY(QString deviceName READ deviceName NOTIFY deviceNameChanged)
    Q_PROPERTY(PlatformStatus status READ status NOTIFY statusChanged)
    Q_PROPERTY(SciMockDevice* mockDevice READ mockDevice CONSTANT)
    Q_PROPERTY(SciScrollbackModel* scrollbackModel READ scrollbackModel CONSTANT)
    Q_PROPERTY(SciFilterScrollbackModel* filterScrollbackModel READ filterScrollbackModel CONSTANT)
    Q_PROPERTY(SciSearchScrollbackModel* searchScrollbackModel READ searchScrollbackModel CONSTANT)
    Q_PROPERTY(SciCommandHistoryModel* commandHistoryModel READ commandHistoryModel CONSTANT)
    Q_PROPERTY(SciFilterSuggestionModel* filterSuggestionModel READ filterSuggestionModel CONSTANT)
    Q_PROPERTY(SciMessageQueueModel* messageQueueModel READ messageQueueModel CONSTANT)

    Q_PROPERTY(SciPlatformValidation* platformValidation READ platformValidation CONSTANT)
    Q_PROPERTY(SciPlatformTestModel* platformTestModel READ platformTestModel CONSTANT)
    Q_PROPERTY(SciPlatformTestMessageModel* platformTestMessageModel READ platformTestMessageModel CONSTANT)

    Q_PROPERTY(QString errorString READ errorString WRITE setErrorString NOTIFY errorStringChanged)
    Q_PROPERTY(bool programInProgress READ programInProgress NOTIFY programInProgressChanged)
    Q_PROPERTY(bool sendMessageInProgress READ sendMessageInProgress NOTIFY sendMessageInProgressChanged)
    Q_PROPERTY(bool sendQueueInProgress READ sendQueueInProgress NOTIFY sendQueueInProgressChanged)
    Q_PROPERTY(bool acquirePortInProgress READ acquirePortInProgress NOTIFY acquirePortInProgressChanged)

public:
    SciPlatform(SciPlatformSettings *settings, strata::PlatformManager *platformManager, QObject *parent = nullptr);

    virtual ~SciPlatform();

    enum PlatformStatus {
        Disconnected,
        Connected,
        Ready,
        NotRecognized,
    };
    Q_ENUM(PlatformStatus)

    enum SendMessageErrorType {
        NoError,
        NotConnectedError,
        JsonError,
        PlatformError,
        QueueError,
    };
    Q_ENUM(SendMessageErrorType)

    // redeclaration of Type Q_ENUM required for custom-type properties to work properly in QML
    // because Q_ENUM macro is constrained to the class it is used in and doesn't work well between classes
    Q_ENUM(strata::device::Device::Type)

    QByteArray deviceId() const;
    strata::device::Device::Type deviceType() const;
    void setDeviceType(const strata::device::Device::Type &type);
    void setPlatform(const strata::platform::PlatformPtr& platform);
    QString verboseName() const;
    void setVerboseName(const QString &verboseName);
    QString appVersion() const;
    void setAppVersion(const QString &appVersion);
    QString bootloaderVersion() const;
    void setBootloaderVersion(const QString &bootloaderVersion);
    SciPlatform::PlatformStatus status() const;
    void setStatus(SciPlatform::PlatformStatus status);
    SciMockDevice* mockDevice() const;
    SciScrollbackModel* scrollbackModel() const;
    SciCommandHistoryModel* commandHistoryModel() const;
    SciFilterSuggestionModel* filterSuggestionModel() const;
    SciFilterScrollbackModel* filterScrollbackModel() const;
    SciSearchScrollbackModel* searchScrollbackModel() const;
    SciMessageQueueModel* messageQueueModel() const;
    SciPlatformTestModel* platformTestModel() const;
    SciPlatformTestMessageModel* platformTestMessageModel() const;
    SciPlatformValidation* platformValidation() const;
    QString errorString() const;
    void setErrorString(const QString &errorString);
    bool programInProgress() const;
    QString deviceName() const;
    void setDeviceName(const QString &deviceName);
    bool sendMessageInProgress();
    bool sendQueueInProgress();
    bool acquirePortInProgress();

    void resetPropertiesFromDevice();
    Q_INVOKABLE void sendMessage(const QString &message, bool onlyValidJson);
    Q_INVOKABLE QVariantMap queueMessage(const QString &message, bool onlyValidJson);
    Q_INVOKABLE void sendQueue();

    Q_INVOKABLE bool programDevice(QString filePath, bool doBackup=true);
    Q_INVOKABLE QString saveDeviceFirmware(QString filePath);
    Q_INVOKABLE bool acquirePort();

    //settings handlers
    void storeCommandHistory(const QStringList &list);
    void storeExportPath(const QString &exportPath);
    void storeAutoExportPath(const QString &autoExportPath);

signals:
    void deviceTypeChanged();
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
    void sendMessageResultReceived(QVariantMap error);
    void sendQueueFinished(QVariantMap error);
    void messageReceived();
    void sendMessageInProgressChanged();
    void sendQueueInProgressChanged();
    void acquirePortInProgressChanged();
    void acquirePortRequestFailed();

private slots:
    void messageFromDeviceHandler(strata::platform::PlatformMessage message);
    void messageToDeviceHandler(QByteArray rawMessage, uint msgNumber, QString errorString);
    void deviceErrorHandler(strata::device::Device::ErrorCode errorCode, QString errorString);
    void flasherProgramProgressHandler(int chunk, int total);
    void flasherBackupProgressHandler(int chunk, int total);
    void flasherRestoreProgressHandler(int chunk, int total);

    void flasherOperationStateChangedHandler(
            strata::FlasherConnector::Operation operation,
            strata::FlasherConnector::State state,
            QString errorString);

    void flasherFinishedHandler(strata::FlasherConnector::Result result);

private:
    void setProgramInProgress(bool programInProgress);
    void setSendMessageInProgress(bool sendMessageInProgress);
    void setSendQueueInProgress(bool sendQueueInProgress);
    void setAcquirePortInProgress(bool acquirePortInProgress);
    bool sendNextInQueue();
    QVariantMap extractJsonError(const QJsonParseError &error);

    strata::platform::PlatformPtr platform_;
    QByteArray deviceId_;
    strata::device::Device::Type deviceType_;
    QString verboseName_;
    QString appVersion_;
    QString bootloaderVersion_;
    PlatformStatus status_;
    QString errorString_;
    bool programInProgress_ = false;
    QString deviceName_;
    SciMockDevice* mockDevice_;
    SciScrollbackModel *scrollbackModel_;
    SciCommandHistoryModel *commandHistoryModel_;
    SciPlatformSettings *settings_;
    SciFilterSuggestionModel *filterSuggestionModel_;
    SciFilterScrollbackModel *filterScrollbackModel_;
    SciSearchScrollbackModel *searchScrollbackModel_;
    SciMessageQueueModel *messageQueueModel_;
    QPointer<strata::FlasherConnector> flasherConnector_;
    strata::PlatformManager *platformManager_;
    SciPlatformTestModel *platformTestModel_;
    SciPlatformTestMessageModel *platformTestMessageModel_;
    SciPlatformValidation *platformValidation_;
    uint currentMessageId_ = 0;
    bool sendMessageInProgress_ = false;
    bool sendQueueInProgress_ = false;
    std::chrono::milliseconds sendQueueDelay_ = std::chrono::milliseconds(50);
    bool acquirePortInProgress_ = false;
};
