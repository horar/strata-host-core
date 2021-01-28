#pragma once

#include <PlatformInterface/core/CoreInterface.h>

#include <QObject>
#include <QStringList>
#include <QJsonObject>


class AdjustControllerManager: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(AdjustControllerManager)

public:
    AdjustControllerManager(CoreInterface *coreInterface, QObject *parent = nullptr);
    ~AdjustControllerManager();

    enum ProgressState {
        DownloadState,
        ClearDataState,
        PrepareState,
        ProgramState,
        SetDataState,
        DoneState,
    };

    Q_INVOKABLE void adjustController(int deviceId);

signals:
    void jobProgressUpdate(int deviceId, float progress);
    void jobStatusChanged(int deviceId, QString status, QString errorString);

private slots:
    void replyHandler(QJsonObject message);
    void jobUpdateHandler(QJsonObject message);

private:
    CoreInterface *coreInterface_;
    QList<int> requestedDeviceIds_;
    QHash<QString, int> jobIdHash_;

    /*0.99 together*/
    const float downloadStateRange_ = 0.10;
    const float clearDataStateRange_ = 0.02;
    const float prepareStateRange_ = 0.05;
    const float programStateRange_ = 0.80;
    const float setDataStateRange_ = 0.02;

    void notifyProgressChange(int deviceId, ProgressState state, float stateProgress);
    void notifyFailure(int deviceId, const QJsonObject &payload);
    float resolveOverallProgress(ProgressState state, float stateProgress);
};
