/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#pragma once

#include <PlatformInterface/core/CoreInterface.h>

#include <QObject>
#include <QHash>
#include <QString>
#include <QJsonObject>

namespace strata::strataRPC {
    class StrataClient;
}

class FirmwareUpdater: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(FirmwareUpdater)

public:
    FirmwareUpdater(strata::strataRPC::StrataClient *strataClient, CoreInterface *coreInterface, QObject *parent = nullptr);
    ~FirmwareUpdater();

    // program assisted controller with the newest firmware (no backup):
    Q_INVOKABLE bool programAssistedController(QString deviceId);
    // program embedded platform without firmware with the newest firmware (no backup):
    Q_INVOKABLE bool programEmbeddedWithoutFw(QString deviceId);
    // program (update) platform with new firmware (do old firmware backup):
    Q_INVOKABLE bool programFirmware(QString deviceId, QString firmwareUri, QString firmwareMD5);

    Q_INVOKABLE bool isFirmwareUpdateInProgress(QString deviceId) const;
    Q_INVOKABLE QJsonObject getFirmwareUpdateData(QString deviceId, QString firmwareUri, QString firmwareMD5) const;

signals:
    void jobStarted(QString deviceId, QString firmwareUri, QString firmwareMD5);
    void jobProgressUpdate(QString deviceId, QString status, float progress);
    void jobFinished(QString deviceId, QString errorString);
    void jobError(QString deviceId, QString errorString);

private slots:
    void replyHandler(QJsonObject payload);
    void jobUpdateHandler(QJsonObject payload);

private:
    enum class Action {
        ProgramAssistedController,
        ProgramEmbeddedWithoutFw,
        ProgramFirmware
    };
    enum class JobType {
        Download,
        Prepare,
        Backup,
        ClearFwClassId,
        Flash,
        Restore,
        SetFwClassId,
        Finished,
        Unknown
    };
    enum class JobStatus {
        Running,
        Success,
        Unsuccess,
        Failure,
        Unknown
    };

    struct FlashingData {
        QString firmwareUri;
        QString firmwareMd5;
        QString status;
        Action action;
        float progress;
        FlashingData(Action a, const QString& uri, const QString& md5) :
            firmwareUri(uri),
            firmwareMd5(md5),
            action(a),
            progress(0.0f)
        { }
    };

    bool requestDevice(const QString& deviceId, Action action, const QString& firmwareUri, const QString& firmwareMD5);

    bool sendCommand(const QString& deviceId, const QString& command, const QJsonObject& payload);

    bool programAssistCntrlHandler(const QHash<QString,FlashingData>::Iterator deviceIter, const QJsonObject& payload);
    bool onlyProgramFwHandler(const QHash<QString,FlashingData>::Iterator deviceIter, const QJsonObject& payload);
    bool backupAndProgramFwHandler(const QHash<QString,FlashingData>::Iterator deviceIter, const QJsonObject& payload);

    void simpleJob(JobType jobType, const QHash<QString,FlashingData>::Iterator deviceIter, const QJsonObject& payload, float progress);
    void progressJob(JobType jobType, const QHash<QString,FlashingData>::Iterator deviceIter, const QJsonObject& payload);
    void finishedJob(const QHash<QString,FlashingData>::Iterator deviceIter, const QJsonObject& payload);

    QString acquireErrorString(const QJsonObject& payload) const;
    JobType acquireJobType(const QJsonObject& payload) const;
    JobStatus acquireJobStatus(const QJsonObject& payload) const;

    void notifyProgressChange(const QHash<QString,FlashingData>::Iterator deviceIter, JobType jobType, float progress);

    float resolveOverallProgress(Action action, JobType jobType, float progress) const;
    QString resolveStatus(JobType jobType, float progress) const;

    void logError(const QString& errorString, const QString& deviceId, Action action, JobType jobType);

    strata::strataRPC::StrataClient *strataClient_;
    CoreInterface *coreInterface_;
    QHash<QString /*deviceId*/, FlashingData> requestedDevices_;
    QHash<QString /*jobId*/, QString /*deviceId*/> jobIdHash_;
};
