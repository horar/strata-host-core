/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include "Authenticator.h"
#include "RestClient.h"

#include <PlatformManager.h>
#include <FlasherConnector.h>
#include <DownloadManager.h>

#include <QObject>
#include <QPointer>
#include <QNetworkAccessManager>


class PrtModel : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(PrtModel)

    Q_PROPERTY(int deviceCount READ deviceCount NOTIFY deviceCountChanged)
    Q_PROPERTY(Authenticator* authenticator READ authenticator CONSTANT)
    Q_PROPERTY(RestClient* restClient READ restClient CONSTANT)
    Q_PROPERTY(QString bootloaderFilepath READ bootloaderFilepath NOTIFY bootloaderFilepathChanged)
    Q_PROPERTY(QString serverType READ serverType CONSTANT)
    Q_PROPERTY(bool debugBuild READ debugBuild CONSTANT)

public:
    explicit PrtModel(QObject *parent = nullptr);
    virtual ~PrtModel();

    int deviceCount() const;
    Authenticator* authenticator();
    RestClient* restClient();
    QString bootloaderFilepath();
    QString serverType() const;
    bool debugBuild() const;

    Q_INVOKABLE QString deviceFirmwareVersion() const;
    Q_INVOKABLE QString deviceFirmwareVerboseName() const;

    Q_INVOKABLE QString devicePlatformId() const;
    Q_INVOKABLE QString deviceClassId() const;

    Q_INVOKABLE QString deviceControllerPlatformId() const;
    Q_INVOKABLE QString deviceControllerClassId() const;

    Q_INVOKABLE bool isAssistedDeviceConnected() const;

    Q_INVOKABLE void downloadBinaries(
            QString bootloaderUrl = QString(),
            QString bootloaderMd5 = QString(),
            QString firmwareUrl = QString(),
            QString firmwareMd5 = QString());

    Q_INVOKABLE void identifyBootloader();
    Q_INVOKABLE void programDevice();
    Q_INVOKABLE void notifyServiceAboutRegistration(
            const QString &classId,
            const QString &platformId);

    Q_INVOKABLE void setPlatformId(
            const QString &classId,
            const QString &platformId,
            int boardCount);

    Q_INVOKABLE void setAssistedPlatformId(const QVariantMap &data);

    Q_INVOKABLE void startBootloader();
    Q_INVOKABLE void startApplication();

    Q_INVOKABLE void clearBinaries();
    Q_INVOKABLE void abortDownload();

    Q_INVOKABLE void startDeviceScan();
    Q_INVOKABLE void stopDeviceScan();

signals:
    void deviceInfoChanged(QByteArray deviceId);
    void boardDisconnected(QByteArray deviceId);

    void deviceCountChanged();
    void bootloaderFilepathChanged();
    void downloadFirmwareFinished(QString errorString);
    void identifyBootloaderFinished(QString errorString);
    void flasherOperationStateChanged(
            strata::FlasherConnector::Operation operation,
            strata::FlasherConnector::State state,
            QString errorString);

    void flasherProgress(int chunk, int total);
    void flasherFinished(strata::FlasherConnector::Result result);
    void notifyServiceFinished(int boardCount, QString errorString);
    void setPlatformIdFinished(QString errorString);
    void setAssistedPlatformIdFinished(QString statusString);
    void startBootloaderFinished(QString errorString);
    void startApplicationFinished(QString errorString);

private slots:
    void deviceInfoChangeHandler(const QByteArray& deviceId, bool recognized, bool inBootloader);
    void deviceDisconnectedHandler(const QByteArray& deviceId);
    void flasherFinishedHandler(strata::FlasherConnector::Result result);
    void downloadFinishedHandler(QString groupId, QString errorString);

private:
    strata::PlatformManager platformManager_;
    QList<strata::platform::PlatformPtr> platformList_;
    QPointer<strata::FlasherConnector> flasherConnector_;
    QNetworkAccessManager networkManager_;
    strata::DownloadManager downloadManager_;
    RestClient restClient_;
    Authenticator authenticator_;
    QUrl cloudServiceUrl_;
    QUrl fileServiceUrl_;
    QString serverType_;

    QString downloadJobId_;
    QPointer<QTemporaryFile> bootloaderFile_;
    QPointer<QTemporaryFile> firmwareFile_;

    bool fakeDownloadBinaries(
                const QString &bootloaderUrl = QString(),
                const QString &firmwareUrl = QString());

    QString resolveConfigFilePath();
    void readConfigFile();
};
