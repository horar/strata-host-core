#ifndef BOARD_MANAGER_H
#define BOARD_MANAGER_H

#include <set>
#include <memory>

#include <QObject>
#include <QString>
#include <QTimer>
#include <QHash>
#include <QVariantMap>
#include <QVector>
#include <QSharedPointer>
#include <QMutex>

#include <SerialDevice.h>
#include <DeviceProperties.h>


namespace strata {

    class DeviceOperations;

    class BoardManager : public QObject
    {
        Q_OBJECT
        Q_DISABLE_COPY(BoardManager)

        Q_PROPERTY(QVector<int> readyDeviceIds READ readyDeviceIds NOTIFY readyDeviceIdsChanged)

    public:
        BoardManager();
        ~BoardManager();

        /**
         * Initialize BoardManager (start managing connected devices).
         * @param requireFwInfoResponse if true require response to get_firmware_info command during device identification
         */
        void init(bool requireFwInfoResponse = true);

        /**
         * Send a message to the device.
         * @param connectionId device connection ID
         * @param message message to send to the device
         */
        [[deprecated("Do not use this function anymore, it will be deleted soon.")]]
        Q_INVOKABLE void sendMessage(const int connectionId, const QString& message);

        /**
         * Disconnect from the device.
         * @param deviceId device ID
         * @return true if device was disconnected, otherwise false
         */
        Q_INVOKABLE bool disconnect(const int deviceId);

        /**
         * Reconnect the device.
         * @param deviceId device ID
         * @return true if device was reconnected (and identification process has started), otherwise false
         */
        Q_INVOKABLE bool reconnect(const int deviceId);

        /**
         * Get smart pointer to the device.
         * @param deviceId device ID
         */
        SerialDevicePtr device(const int deviceId);

        /**
         * Get information about connected device (platform ID, bootloader version, ...).
         * @param connectionId device connection ID
         * @return QVariantMap filled with information about device
         */
        [[deprecated("Do not use this function anymore, it will be deleted soon.")]]
        Q_INVOKABLE QVariantMap getConnectionInfo(const int connectionId);

        /**
         * Get list of available device IDs.
         * @return list of available device IDs (those, which have serial port opened)
         */
        QVector<int> readyDeviceIds();

        /**
         * Get device property.
         * @param connectionId device connection ID
         * @param property value from enum DeviceProperties
         * @return QString filled with value of required property
         */
        [[deprecated("Do not use this function anymore, it will be deleted soon.")]]
        QString getDeviceProperty(const int connectionId, const DeviceProperties property);

    signals:
        /**
         * Emitted when new board is connected to computer.
         * @param deviceId device ID
         */
        void boardConnected(int deviceId);

        /**
         * Emitted when board is disconnected.
         * @param deviceId device ID
         */
        void boardDisconnected(int deviceId);

        /**
         * Emitted when board is ready for communication.
         * @param deviceId device ID
         * @param recognized true when board was recognized (identified), otherwise false
         */
        void boardReady(int deviceId, bool recognized);

        /**
         * Emitted when error occures during communication with the board.
         * @param deviceId device ID
         * @param message error description
         */
        void boardError(int deviceId, QString message);

        /**
         * Emitted when there is available new message from the connected board.
         * @param deviceId device ID
         * @param message message from board
         */
        // DEPRECATED
        void newMessage(int deviceId, QString message);

        /**
         * Emitted when required operation cannot be fulfilled (e.g. device ID does not exist).
         * @param deviceId device ID
         */
        // DEPRECATED
        void invalidOperation(int deviceId);

        /**
         * Emitted when device IDs has changed (available device ID list has changed).
         */
        void readyDeviceIdsChanged();

    private slots:
        void checkNewSerialDevices();
        void handleNewMessage(QString message);  // DEPRECATED
        void handleOperationFinished(int operation, int);
        void handleOperationError(QString message);
        void handleSerialDeviceError(int errCode, QString errStr);

    private:
        void computeListDiff(std::set<int>& list, std::set<int>& added_ports, std::set<int>& removed_ports);
        bool addSerialPort(const int deviceId);
        void removeSerialPort(const int deviceId);

        void logInvalidDeviceId(const QString& message, const int deviceId) const;

        QTimer timer_;

        QMutex mutex_;

        // Access to next 3 members should be protected by mutex (one mutex for all) in case of multithread usage.
        // Do not emit signals in block of locked code (because their slots are executed immediately in QML
        // and deadlock can occur if from QML is called another function which uses same mutex).
        std::set<int> serialPortsList_;
        QHash<int, QString> serialIdToName_;
        QHash<int, SerialDevicePtr> openedSerialPorts_;

        QHash<int, QSharedPointer<DeviceOperations>> serialDeviceOperations_;

        // flag if require response to get_firmware_info command
        bool reqFwInfoResp_;
    };

}

#endif
