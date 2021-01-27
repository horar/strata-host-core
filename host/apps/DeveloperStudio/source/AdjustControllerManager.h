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

    const int downloadStateRange_ = 10;
    const int clearDataStateRange_ = 2;
    const int prepareStateRange_ = 5;
    const int programStateRange_ = 80;
    const int setDataStateRange_ = 2;

    void notifyProgressChange(int deviceId, ProgressState state, float stateProgress);
    void notifyFailure(int deviceId, const QJsonObject &payload);
    float resolveOverallProgress(ProgressState state, float stateProgress);
};
