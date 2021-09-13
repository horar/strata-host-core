#pragma once

#include <PlatformInterface/core/CoreInterface.h>

#include <QObject>
#include <QHash>
#include <QPair>
#include <QString>
#include <QJsonObject>

namespace strata::strataRPC {
    class StrataClient;
}

class ProgramFirmware: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(ProgramFirmware)

public:
    ProgramFirmware(strata::strataRPC::StrataClient *strataClient, CoreInterface *coreInterface, QObject *parent = nullptr);
    ~ProgramFirmware();

    // program platform with newest firmware (no backup):
    Q_INVOKABLE bool programAssisted(QString deviceId);
    Q_INVOKABLE bool programEmbedded(QString deviceId);
    // program platform with specific firmware:
    Q_INVOKABLE bool programSpecificFirmware(QString deviceId, QString firmwareUri, QString firmwareMD5);

    Q_INVOKABLE QJsonObject acquireProgramFirmwareData(QString deviceId, QString firmwareUri, QString firmwareMD5) const;

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
        ProgramAssisted,
        ProgramEmbedded,
        ProgramSpecificFirmware,
    };
    enum class JobType {
        Download,
        Prepare,
        ClearFwClassId,
        Backup,
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
        QString uri;
        QString md5;
        QString status;
        Action action;
        float progress;
        FlashingData(Action a, const QString& uri, const QString& md5) :
            uri(uri),
            md5(md5),
            action(a),
            progress(0.0f)
        { }
    };

    bool requestDevice(const QString& deviceId, Action action, const QString& firmwareUri, const QString& firmwareMD5);

    bool sendCommand(const QString& deviceId, const QString& command, const QJsonObject& payload);

    bool programAssistedController(const QHash<QString,FlashingData>::Iterator deviceIter, const QJsonObject& payload);
    bool programFirmware(const QHash<QString,FlashingData>::Iterator deviceIter, const QJsonObject& payload);
    bool backupAndProgram(const QHash<QString,FlashingData>::Iterator deviceIter, const QJsonObject& payload);

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
