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
    DeviceOperations(SerialDevicePtr device);
    ~DeviceOperations();

    void identify(bool requireFwInfoResponse = true);

    void prepareForFlash();

    void flashFirmwareChunk(QVector<quint8> chunk, int chunk_number);

    void startApplication();

    void cancelOperation();

    int deviceId() const;

    friend QDebug operator<<(QDebug dbg, const DeviceOperations* dev_op);

    enum class Operation {
        None,
        Identify,
        PrepareForFlash,
        FlashFirmwareChunk,
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
        ReadyForFlashFw,
        FlashFwChunk,
        StartApplication,
        Timeout
    };

    enum class Activity {
        None,
        WaitingForFirmwareInfo,
        WaitingForPlatformId,
        WaitingForUpdateFw,
        WaitingForFlashFwChunk,
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

    SerialDevicePtr device_;

    QTimer responseTimer_;

    QVector<quint8> chunk_;
    int chunkNumber_;

    uint deviceId_;

    Operation operation_;

    State state_;

    Activity activity_;

    bool ackReceived_;

    bool reqFwInfoResp_;
};

}  // namespace

#endif
