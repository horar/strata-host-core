/*
 * Copyright (c) 2018-2021 onsemi.
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

#include <PlatformManager.h>
#include <FlasherConnector.h>
#include <Mock/MockDevice.h>
#include <QObject>
#include <QPointer>


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
    Q_PROPERTY(QString errorString READ errorString WRITE setErrorString NOTIFY errorStringChanged)
    Q_PROPERTY(bool programInProgress READ programInProgress NOTIFY programInProgressChanged)

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
    QString errorString() const;
    void setErrorString(const QString &errorString);
    bool programInProgress() const;
    QString deviceName() const;
    void setDeviceName(const QString &deviceName);

    void resetPropertiesFromDevice();
    Q_INVOKABLE void sendMessage(const QString &message, bool onlyValidJson);
    Q_INVOKABLE bool programDevice(QString filePath, bool doBackup=true);
    Q_INVOKABLE QString saveDeviceFirmware(QString filePath);

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
    void sendMessageResultReceived(SendMessageErrorType type, QVariantMap data);

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
    QPointer<strata::FlasherConnector> flasherConnector_;
    strata::PlatformManager *platformManager_;
    uint currentMessageId_ = 0;

    void setProgramInProgress(bool programInProgress);
    void setMessageSendInProgress(bool messageSendInProgress);
};
