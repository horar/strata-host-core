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
    DeviceOperations(SerialDeviceShPtr device);

    void identify();

    void prepareForFlash();

    void flashFirmwareChunk(QVector<quint8> chunk, int chunk_number);

    void startApplication();

    // TODO
    void cancelOperation();

    friend QDebug operator<<(QDebug dbg, const DeviceOperations* dev_op);

signals:
    void identified();
    void readyForFlashFw();
    void fwChunkFlashed(int chunk_number);
    void applicationStarted();
    void timeout();
    void cancelled();
    void error(QString msg);

    // signals only for internal use:
    // Qt5 private signals: https://woboq.com/blog/how-qt-signals-slots-work-part2-qt5.html
    void nextStep(QPrivateSignal);

private:
    enum class Operation {
        None,
        Identify,
        PrepareForFlash,
        FlashFirmwareChunk,
        StartApplication
    };

    enum class State {
        None,
        GetPlatformId,
        UpdateFirmware,
        ReadyForFlashFw,
        FlashFwChunk,
        FwChunkFlashed,
        StartApplication,
        ApplicationStarted,
        Timeout
    };

    enum class Activity {
        None,
        WaitingForPlatformId,
        WaitingForUpdateFw,
        WaitingForFlashFwChunk,
        WaitingForStartApp
    };

    void startOperation(Operation oper);

    void process();

    void handleResponseTimeout();

    void handleDeviceError(int deviceId, QString msg);

    void handleDeviceResponse(const int /* device_id */, const QByteArray& data);

    bool parseDeviceResponse(const QByteArray& data, bool& is_ack);

    void resetInternalStates();

    QByteArray createFlashFwJson();

    SerialDeviceShPtr device_;

    QTimer response_timer_;

    QVector<quint8> chunk_;
    int chunk_number_;

    uint device_id_;

    Operation operation_;

    State state_;

    Activity activity_;

    bool ack_received_;
};

}  // namespace

#endif
