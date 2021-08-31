#pragma once

#include <StrataRPC/StrataClient.h>
#include <PlatformInterface/core/CoreInterface.h>

#include <QObject>
#include <QMap>
#include <QHash>
#include <QString>
#include <QJsonObject>

class FirmwareManager: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(FirmwareManager)

public:
    FirmwareManager(strata::strataRPC::StrataClient *strataClient, CoreInterface *coreInterface, QObject *parent = nullptr);
    ~FirmwareManager();

    enum ProgressState {
        DownloadState,
        PrepareState,
        BackupState,
        ProgramState,
        DoneState,
    };

    struct FlashingData {
        QString uri_;
        QString md5_;
        QString jobId_;
        QString status_;
        QString error_;
        float progress_;
    };

    Q_INVOKABLE bool updateFirmware(QString deviceId, QString uri, QString md5);
    Q_INVOKABLE QJsonObject acquireUpdateFirmwareData(QString deviceId, QString uri, QString md5) const;

signals:
    void updateFirmwareJobProgress(QString deviceId, QString status, float progress);
    void updateFirmwareJobFinished(QString deviceId, QString status, QString errorString);

private slots:
    void replyHandler(QJsonObject payload);
    void jobUpdateHandler(QJsonObject payload);

private:
    strata::strataRPC::StrataClient *strataClient_;
    CoreInterface *coreInterface_;
    QMap<QString, FlashingData> deviceData_;
    QHash<QString /*jobId*/, QString /*deviceId*/> jobIdHash_;

    /*0.99 together*/
    const float downloadStateRange_ = 0.25;
    const float prepareStateRange_ = 0.25;
    const float backupStateRange_ = 0.25;
    const float programStateRange_ = 0.24;

    float resolveOverallProgress(ProgressState state, float stateProgress = 0.0);
    QString acquireErrorString(const QJsonObject &payload);
};
