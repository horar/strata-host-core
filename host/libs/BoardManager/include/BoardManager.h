#ifndef BOARD_MANAGER_H
#define BOARD_MANAGER_H

#include <string>
#include <set>
#include <QObject>
#include <QString>
#include <QTimer>
#include <QHash>
#include <QVariantMap>
#include <QVector>
#include "SerialDevice.h"

namespace spyglass {

    typedef std::shared_ptr<SerialDevice> SerialDeviceShPtr;

    class BoardManager : public QObject
    {
        Q_OBJECT
        Q_DISABLE_COPY(BoardManager)

        Q_PROPERTY(QVector<int> connectionIds READ connectionIds NOTIFY connectionIdsChanged)

    public:
        BoardManager();

        /**
         * Initialize BoardManager (start managing connected devices).
         */
        void init();

        /**
         * Send a message to the device.
         * @param connectionId device connection ID
         * @param message message to send to the device
         */
        Q_INVOKABLE void sendMessage(const int connectionId, const QString& message);

        /**
         * Disconnect from the device.
         * @param connectionId device connection ID
         */
        Q_INVOKABLE void disconnect(const int connectionId);

        /**
         * Reconnect the device.
         * @param connectionId device connection ID
         */
        Q_INVOKABLE void reconnect(const int connectionId);

        /**
         * Get information about connected device (platform ID, bootloader version, ...).
         * @param connectionId device connection ID
         * @return QVariantMap filled with information about device
         */
        Q_INVOKABLE QVariantMap getConnectionInfo(const int connectionId);

        /**
         * Get list of available connection IDs.
         * @return list of available connection IDs
         */
        QVector<int> connectionIds();

    signals:
        /**
         * Emitted when new board is connected to computer.
         * @param connectionId device connection ID
         */
        void boardConnected(int connectionId);

        /**
         * Emitted when board is disconnected.
         * @param connectionId device connection ID
         */
        void boardDisconnected(int connectionId);

        /**
         * Emitted when board is ready for communication.
         * @param connectionId device connection ID
         * @param recognized true when board was recognized (identified), otherwise false
         */
        void boardReady(int connectionId, bool recognized);

        /**
         * Emitted when error occured during communication with the board.
         * @param connectionId device connection ID
         * @param message error description
         */
        void boardError(int connectionId, QString message);

        /**
         * Emitted when there is available new message from the connected board.
         * @param connectionId device connection ID
         * @param message message from board
         */
        void newMessage(int connectionId, QString message);

        /**
         * Emitted when required operation cannot be fulfilled (e.g. connection ID does not exist).
         * @param connectionId device connection ID
         */
        void invalidOperation(int connectionId);

        /**
         * Emitted when connection IDs has changed (available connection ID list has changed).
         */
        void connectionIdsChanged();

    private slots:
        void checkNewSerialDevices();

    private:
        void computeListDiff(std::set<int>& list, std::set<int>& added_ports, std::set<int>& removed_ports);
        bool addedSerialPort(const int connectionId);
        void removedSerialPort(const int connectionId);

        QTimer timer_;

        // Access to these 3 members should be protected by mutex (one mutex for all) in case of multithread usage.
        // Do not emit signals in block of locked code (because their slots are executed immediately in QML
        // and deadlock can occur if from QML is called another function which uses same mutex).
        std::set<int> serialPortsList_;
        QHash<int, QString> serialIdToName_;
        QHash<int, SerialDeviceShPtr> openedSerialPorts_;
    };

}

#endif
