#ifndef DEVICE_OPERATIONS_H
#define DEVICE_OPERATIONS_H

#include <QObject>
#include <QByteArray>
#include <QTimer>
#include <QVector>

#include <SerialDevice.h>

namespace strata {

class DeviceOperations : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(DeviceOperations)

public:
    DeviceOperations(const SerialDevicePtr& device);
    ~DeviceOperations();

    void identify(bool requireFwInfoResponse = true);

    void switchToBootloader();

    void flashFirmwareChunk(const QVector<quint8>& chunk, int chunkNumber);

    void backupFirmwareChunk(bool firstChunk);

    void startApplication();

    void cancelOperation();

    int deviceId() const;

    QVector<quint8> recentFirmwareChunk() const;

    friend QDebug operator<<(QDebug dbg, const DeviceOperations* devOp);

    enum class Operation {
        None,
        Identify,
        SwitchToBootloader,
        FlashFirmwareChunk,
        BackupFirmwareChunk,
        StartApplication,
        // special values for finished signal:
        Cancel,
        Timeout
    };

signals:
    void finished(int operation, int data = -1);
    void error(QString msg);

    // signals only for internal use:
    // Qt5 private signals: https://woboq.com/blog/how-qt-signals-slots-work-part2-qt5.html
    void nextStep(QPrivateSignal);

private:
    enum class State {
        None,
        GetFirmwareInfo,
        GetPlatformId,
        UpdateFirmware,
        SwitchedToBootloader,
        FlashFwChunk,
        BackupFwChunk,
        StartApplication,
        Timeout
    };

    enum class Activity {
        None,
        WaitingForFirmwareInfo,
        WaitingForPlatformId,
        WaitingForSwitchToBtldr,
        WaitingForFlashFwChunk,
        WaitingForBackupFwChunk,
        WaitingForStartApp
    };

    void startOperation(Operation operation);

    void finishOperation(Operation operation, int data = -1);

    void process();

    void handleResponseTimeout();

    void handleDeviceError(int errCode, QString msg);

    void handleDeviceResponse(const QByteArray& data);

    bool parseDeviceResponse(const QByteArray& data, bool& isAck);

    void resetInternalStates();

    QByteArray createFlashFwJson();
    QByteArray createBackupFwJson();

    SerialDevicePtr device_;

    QTimer responseTimer_;

    QVector<quint8> chunk_;
    int chunkNumber_;
    uint chunkRetryCount_;

    uint deviceId_;

    Operation operation_;

    State state_;

    Activity activity_;

    bool ackReceived_;

    bool reqFwInfoResp_;

    bool firstBackupChunk_;
};

}  // namespace

#endif
