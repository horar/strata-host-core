#ifndef BOARD_MANAGER_H
#define BOARD_MANAGER_H

#include <set>
#include <memory>
#include <chrono>

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QTimer>
#include <QHash>
#include <QVariantMap>
#include <QVector>
#include <QMutex>

#include <Device/Device.h>

namespace strata::device::operation {
    class BaseDeviceOperation;
    enum class Result: int;
}

namespace strata {

    class BoardManager : public QObject
    {
        Q_OBJECT
        Q_DISABLE_COPY(BoardManager)

    public:
        BoardManager();
        ~BoardManager();

        /**
         * Initialize BoardManager (start managing connected devices).
         * @param requireFwInfoResponse if true require response to get_firmware_info command during device identification
         * @param keepDevicesOpen if true communication channel is not released (closed) if device is not recognized
         */
        virtual void init(bool requireFwInfoResponse, bool keepDevicesOpen);

        /**
         * Disconnect from the device.
         * @param deviceId device ID
         * @param disconnectDuration if more than 0, the device will be connected again after the given milliseconds at the earliest;
         *                           if 0 or less, there will be no attempt to reconnect device
         * @return true if device was disconnected, otherwise false
         */
        bool disconnectDevice(const QByteArray& deviceId, std::chrono::milliseconds disconnectDuration = std::chrono::milliseconds(0));

        /**
         * Reconnect the device.
         * @param deviceId device ID
         * @return true if device was reconnected (and identification process has started), otherwise false
         */
        bool reconnectDevice(const QByteArray& deviceId);

        /**
         * Get smart pointer to the device.
         * @param deviceId device ID
         */
        device::DevicePtr device(const QByteArray& deviceId);

        /**
         * Get list of active device IDs.
         * @return list of active device IDs (those, which have
         *         communication channel (serial port) opened)
         */
        QVector<QByteArray> activeDeviceIds();

    signals:
        /**
         * Emitted when new board is connected to computer.
         * @param deviceId device ID
         */
        void boardConnected(QByteArray deviceId);

        /**
         * Emitted when board is disconnected.
         * @param deviceId device ID
         */
        void boardDisconnected(QByteArray deviceId);

        /**
         * Emitted when board properties has changed (and board is ready for communication).
         * @param deviceId device ID
         * @param recognized true when board was recognized (identified), otherwise false
         */
        void boardInfoChanged(QByteArray deviceId, bool recognized);

        /**
         * Emitted when error occures during communication with the board.
         * @param deviceId device ID
         * @param message error description
         */
        void boardError(QByteArray deviceId, QString message);

        /**
         * Emitted when platform_id_changed notification was received (signal only for internal use).
         * @param deviceId devide ID
         */
        void platformIdChanged(QByteArray deviceId, QPrivateSignal);

    protected slots:
        virtual void checkNewSerialDevices();
        virtual void handleOperationFinished(device::operation::Result result, int status, QString errStr);
        virtual void handleDeviceError(device::Device::ErrorCode errCode, QString errStr);

    private slots:
        virtual void checkNotification(QByteArray message);
        virtual void handlePlatformIdChanged(const QByteArray& deviceId);

    protected:
        void computeListDiff(std::set<QByteArray>& list, std::set<QByteArray>& added_ports, std::set<QByteArray>& removed_ports);
        bool addSerialPort(const QByteArray& deviceId);
        bool openDevice(const device::DevicePtr newDevice);
        void startDeviceOperations(const device::DevicePtr device);
        bool removeDevice(const QByteArray& deviceId);

        void logInvalidDeviceId(const QString& message, const QByteArray& deviceId) const;

        QTimer timer_;

        QMutex mutex_;

        // Access to next 4 members should be protected by mutex (one mutex for all) in case of multithread usage.
        // Do not emit signals in block of locked code (because their slots are executed immediately in QML
        // and deadlock can occur if from QML is called another function which uses same mutex).
        std::set<QByteArray> serialPortsList_;
        QHash<QByteArray, QString> serialIdToName_;
        QHash<QByteArray, device::DevicePtr> openedDevices_;
        QHash<QByteArray, QTimer*> reconnectTimers_;

        QHash<QByteArray, std::shared_ptr<device::operation::BaseDeviceOperation>> identifyOperations_;

        // flag if require response to get_firmware_info command
        bool reqFwInfoResp_;
        // flag if communication channel should stay open if device is not recognized
        bool keepDevicesOpen_;

    private:
        void startIdentifyOperation(const device::DevicePtr device);
        static void operationLaterDeleter(device::operation::BaseDeviceOperation* operation);

    };

}

#endif
