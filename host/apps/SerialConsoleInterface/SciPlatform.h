#ifndef SCI_PLATFORM_H
#define SCI_PLATFORM_H

#include "SciScrollbackModel.h"
#include "SciCommandHistoryModel.h"
#include "SciPlatformSettings.h"

#include <BoardManager.h>
#include <FlasherConnector.h>
#include <QObject>
#include <QPointer>

class SciPlatform: public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(SciPlatform)

    Q_PROPERTY(QString deviceId READ deviceId CONSTANT)
    Q_PROPERTY(QString verboseName READ verboseName NOTIFY verboseNameChanged)
    Q_PROPERTY(QString appVersion READ appVersion NOTIFY appVersionChanged)
    Q_PROPERTY(QString bootloaderVersion READ bootloaderVersion NOTIFY bootloaderVersionChanged)
    Q_PROPERTY(PlatformStatus status READ status NOTIFY statusChanged)
    Q_PROPERTY(SciScrollbackModel* scrollbackModel READ scrollbackModel CONSTANT)
    Q_PROPERTY(SciCommandHistoryModel* commandHistoryModel READ commandHistoryModel CONSTANT)
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

    int deviceId();
    void setDevice(strata::device::DevicePtr device);
    QString verboseName();
    void setVerboseName(const QString &verboseName);
    QString appVersion();
    void setAppVersion(const QString &appVersion);
    QString bootloaderVersion();
    void setBootloaderVersion(const QString &bootloaderVersion);
    SciPlatform::PlatformStatus status();
    void setStatus(SciPlatform::PlatformStatus status);
    SciScrollbackModel* scrollbackModel();
    SciCommandHistoryModel* commandHistoryModel();
    QString errorString();
    void setErrorString(const QString &errorString);
    bool programInProgress() const;

    void resetPropertiesFromDevice();
    Q_INVOKABLE bool sendMessage(const QByteArray &message);
    Q_INVOKABLE bool exportScrollback(QString filePath) const;
    Q_INVOKABLE void removeCommandFromHistoryAt(int index);
    Q_INVOKABLE bool programDevice(QString filePath, bool doBackup=true);

signals:
    void verboseNameChanged();
    void appVersionChanged();
    void bootloaderVersionChanged();
    void statusChanged();
    void errorStringChanged();
    void programInProgressChanged();
    void flasherProgramProgress(int chunk, int total);
    void flasherBackupProgress(int chunk);
    void flasherOperationStateChanged(
            strata::FlasherConnector::Operation operation,
            strata::FlasherConnector::State state,
            QString errorString);

    void flasherFinished(strata::FlasherConnector::Result result);


private slots:
    void messageFromDeviceHandler(QByteArray message);
    void messageToDeviceHandler(QByteArray message);
    void deviceErrorHandler(strata::device::Device::ErrorCode errorCode, QString errorString);
    void flasherProgramProgressHandler(int chunk, int total);
    void flasherBackupProgressHandler(int chunk);

    void flasherOperationStateChangedHandler(
            strata::FlasherConnector::Operation operation,
            strata::FlasherConnector::State state,
            QString errorString);

    void flasherFinishedHandler(strata::FlasherConnector::Result result);

private:
    strata::device::DevicePtr device_;
    int deviceId_;
    QString verboseName_;
    QString appVersion_;
    QString bootloaderVersion_;
    PlatformStatus status_;
    QString errorString_;
    bool programInProgress_ = false;

    SciScrollbackModel *scrollbackModel_;
    SciCommandHistoryModel *commandHistoryModel_;
    SciPlatformSettings *settings_;
    QPointer<strata::FlasherConnector> flasherConnector_;

    void setProgramInProgress(bool programInProgress);
};

#endif //SCI_PLATFORM_H
