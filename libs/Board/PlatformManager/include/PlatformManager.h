#pragma once

#include <memory>
#include <chrono>

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QMap>
#include <QHash>
#include <QList>
#include <QVector>

#include <Platform.h>
#include <DeviceScanner.h>
#include <Operations/PlatformOperations.h>

namespace strata {

    class PlatformManager : public QObject
    {
        Q_OBJECT
        Q_DISABLE_COPY(PlatformManager)

    public:
        /**
          * PlatformManager constructor
          * @param requireFwInfoResponse true if response to 'get_firmware_info' command is required, false otherwise
          * @param keepDevicesOpen true if to keep devices open if Identify operation fails, false otherwise
          * @param handleIdentify true if PlatformManager performs Identify operation, false otherwise
          */
        PlatformManager(bool requireFwInfoResponse, bool keepDevicesOpen, bool handleIdentify);

        /**
          * PlatformManager destructor
          */
        ~PlatformManager();

        /**
         * Add a particular device scanner.
         * @param scannerType scanner type
         * @param flags flags defining properties for scanner
         */
        void addScanner(device::Device::Type scannerType, quint32 flags = 0);

        /**
         * Remove a particular device scanner.
         * @param scannerType scanner type
         */
        void removeScanner(device::Device::Type scannerType);

        /**
         * Disconnect and close the platform.
         * @param deviceId device ID
         * @param disconnectDuration if more than 0, the device will be connected again after the given milliseconds at the earliest;
         *                           if 0 or less, there will be no attempt to reconnect device
         * @return true if platform was open and a close attempt was executed, otherwise false
         */
        bool disconnectPlatform(const QByteArray& deviceId, std::chrono::milliseconds disconnectDuration = std::chrono::milliseconds(0));

        /**
         * Reconnect and open the platform.
         * @param deviceId device ID
         * @return true if platform was closed and an open attempt was executed, otherwise false
         */
        bool reconnectPlatform(const QByteArray& deviceId);

        /**
         * Get smart pointer to the opened and/or closed platform.
         * @param deviceId device ID
         * @param open true if open platforms are considered, false otherwise
         * @param closed true if closed platforms are considered, false otherwise
         * @return platform pointer
         */
        platform::PlatformPtr getPlatform(const QByteArray& deviceId, bool open = true, bool closed = false) const;

        /**
         * Get list of smart pointers to all the opened and/or closed platforms.
         * @param open true if open platforms are considered, false otherwise
         * @param closed true if closed platforms are considered, false otherwise
         * @return list of platform pointers
         */
        QList<platform::PlatformPtr> getPlatforms(bool open = true, bool closed = false) const;

        /**
         * Get list of device Ids of all the opened and/or closed platforms.
         * @param open true if open platforms are considered, false otherwise
         * @param closed true if closed platforms are considered, false otherwise
         * @return list of device Ids
         */
        QList<QByteArray> getDeviceIds(bool open = true, bool closed = false);

        /**
         * Get smart pointer to the device scanner.
         * @param scannerType scanner type
         */
        device::scanner::DeviceScannerPtr getScanner(device::Device::Type scannerType);

    signals:
        /**
         * Emitted when new platform is connected and succesfully opened (added to openedPlatforms_).
         * @param deviceId device ID
         */
        void platformAdded(QByteArray deviceId);

        /**
         * Emitted when platform is about to be closed (removed from openedPlatforms_).
         * @param deviceId device ID
         */
        void platformAboutToClose(QByteArray deviceId);

        /**
         * Emitted when platform is disconnected and closed (removed from openedPlatforms_).
         * @param deviceId device ID
         */
        void platformRemoved(QByteArray deviceId);

        /**
         * Emitted when platform was recognized through Identify operation (and is ready for communication).
         * @param deviceId device ID
         * @param recognized true when platform was recognized (identified), otherwise false
         */
        void platformRecognized(QByteArray deviceId, bool isRecognized);

    private slots:
        // from DeviceScanner
        void handleDeviceDetected(platform::PlatformPtr platform);
        void handleDeviceLost(QByteArray deviceId);

        // from Platform
        void handlePlatformOpened();
        void handlePlatformAboutToClose();
        void handlePlatformClosed();
        void handlePlatformTerminated();
        void handlePlatformRecognized(bool isRecognized);
        void handlePlatformIdChanged();
        void handleDeviceError(device::Device::ErrorCode errCode, QString errStr);

    private:
        void startPlatformOperations(const platform::PlatformPtr& platform);

        QMap<device::Device::Type, device::scanner::DeviceScannerPtr> scanners_;
        QHash<QByteArray, platform::PlatformPtr> openedPlatforms_;
        QHash<QByteArray, platform::PlatformPtr> closedPlatforms_;

        platform::operation::PlatformOperations platformOperations_;

        // flag if require response to get_firmware_info command
        const bool reqFwInfoResp_;
        // flag if communication channel should stay open if device is not recognized
        const bool keepDevicesOpen_;
        // flag if Identify is to be done automatically by PlatformManager or manually by other class
        const bool handleIdentify_;
    };

}
