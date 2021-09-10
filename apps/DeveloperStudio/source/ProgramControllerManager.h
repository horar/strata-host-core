#pragma once

#include <StrataRPC/StrataClient.h>
#include <PlatformInterface/core/CoreInterface.h>

#include <QObject>
#include <QStringList>
#include <QJsonObject>
#include <QString>
#include <QHash>


class ProgramControllerManager: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(ProgramControllerManager)

public:
    ProgramControllerManager(strata::strataRPC::StrataClient *strataClient, CoreInterface *coreInterface, QObject *parent = nullptr);
    ~ProgramControllerManager();

    enum ProgressState {
        DownloadState,
        PrepareState,
        ClearDataState,
        ProgramState,
        SetDataState,
        DoneState,
    };

    Q_INVOKABLE void programAssisted(QString deviceId);
    Q_INVOKABLE void programEmbedded(QString deviceId);

signals:
    void jobProgressUpdate(QString deviceId, float progress);
    void jobStatusChanged(QString deviceId, QString status, QString errorString);

private slots:
    void replyHandler(QJsonObject payload);
    void jobUpdateHandler(QJsonObject payload);

private:
    strata::strataRPC::StrataClient *strataClient_;
    CoreInterface *coreInterface_;
    QList<QString> requestedDeviceIds_;
    QHash<QString /*jobId*/, QString /*deviceId*/> jobIdHash_;

    /*0.99 together*/
    const float downloadStateRange_ = 0.10;
    const float prepareStateRange_ = 0.05;
    const float clearDataStateRange_ = 0.02;
    const float programStateRange_ = 0.80;
    const float setDataStateRange_ = 0.02;

    void notifyProgressChange(const QString &deviceId, ProgressState state, float stateProgress);
    void notifyFailure(const QString &deviceId, const QJsonObject &payload);
    float resolveOverallProgress(ProgressState state, float stateProgress);
};
