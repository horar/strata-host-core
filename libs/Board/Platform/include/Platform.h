/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <PlatformMessage.h>
#include <Device.h>

#include <memory>
#include <chrono>

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QMutex>
#include <QReadWriteLock>
#include <QDateTime>
#include <QTimer>

#include <rapidjson/schema.h>

namespace strata::platform {

    namespace command {
        class BasePlatformCommand;
    }
    namespace operation {
        class BasePlatformOperation;
        class Identify;
    }

    class Platform;

    typedef std::shared_ptr<Platform> PlatformPtr;

    class Platform : public QObject
    {
        Q_OBJECT
        Q_DISABLE_COPY(Platform)

    friend class strata::platform::operation::BasePlatformOperation;
    friend class strata::platform::command::BasePlatformCommand;

    public:
        enum class ApiVersion {
            Unknown,
            v1_0,
            v2_0
        };
        Q_ENUM(ApiVersion)

        enum class ControllerType {
            Embedded = 0x01,
            Assisted = 0x02
        };
        Q_ENUM(ControllerType)

        enum class PlatformState {
            Opened,
            AboutToClose,
            Closed,
            Terminated
        };
        Q_ENUM(PlatformState)

        /**
         * Platform constructor
         * @param device pointer
         */
        explicit Platform(const device::DevicePtr& device) noexcept(false);

        /**
         * Platform destructor
         */
        virtual ~Platform();

        /**
         * Open device communication channel.
         * Emits opened() signal in case of success.
         * Emits deviceError(DeviceFailedToOpen) signal in case of failure.
         */
        void open();

        /**
         * Close device communication channel.
         * Emits closed() signal upon completion.
         * @param waitInterval how long to remain in closed state before re-attempting to open the device (0 - stay closed)
         */
        void close(const std::chrono::milliseconds waitInterval = std::chrono::milliseconds::zero());

        /**
         * Terminate all operations, will result in erasure of the platform from PlatformManager
         */
        void terminate();

        /**
         * Send message to device (public).
         * Emits messageSent() signal.
         * @param message message to be written to device
         * @return serial number of the sent message
         */
        unsigned sendMessage(const QByteArray& message);

        // *** Platform properties (start) ***

        /**
         * Get name property.
         * @return name (device property)
         */
        QString name();

        /**
         * Get bootloader version property.
         * @return bootloader version (device property)
         */
        QString bootloaderVer();

        /**
         * Get application version property.
         * @return application version (device property)
         */
        QString applicationVer();

        /**
         * Get platform ID property.
         * @return platform ID (device property)
         */
        QString platformId();

        /**
         * Check if class ID property is set.
         * @return true if class ID is set (true is returned also if class ID is empty string)
         */
        bool hasClassId();

        /**
         * Get class ID property.
         * @return class ID (device property)
         */
        QString classId();

        /**
         * Get controller platform ID property.
         * @return controller platform ID (device property)
         */
        QString controllerPlatformId();

        /**
         * Get controller class ID property.
         * @return controller class ID (device property)
         */
        QString controllerClassId();

        /**
         * Get firmware class ID property.
         * @return firmware class ID (device property)
         */
        QString firmwareClassId();

        /**
         * Get API version property.
         * @return API version (device property)
         */
        ApiVersion apiVersion();

        /**
         * Get controller type property.
         * @return controller type (device property)
         */
        ControllerType controllerType();

        /**
         * Check if controller is connected to platform (dongle is connected to board).
         * This method must be called after Identify operation finishes.
         * @return true if controller is connected to platform, false otherwise
         */
        bool isControllerConnectedToPlatform();

        /**
         * Check if platform was correctly recognized.
         * This method must be called after Identify operation finishes.
         * @return true if platform is recognized, false otherwise
         */
        bool isRecognized();

        // *** Platform properties (end) ***

        /**
         * Get device ID.
         * @return Device ID
         */
        QByteArray deviceId() const;

        /**
         * Get device name given by system (e.g. COM3)
         * @return Device name
         */
        const QString deviceName() const;

        /**
         * Get device type.
         * @return Type of device
         */
        device::Device::Type deviceType() const;

        /**
         * Check if platform device is connected.
         * @return true if device is connected, false otherwise
         */
        bool deviceConnected() const;

        /**
         * Check if platform is in open state.
         * @return true if platform is in open state, false otherwise
         */
        bool isOpen() const;

        /**
         * Reset receiving messages from device (clear internel buffers, etc.).
         */
        void resetReceiving();

        /**
         * Set termination cause
         * @param terminationCause error string describing cause of termination, empty (null) when termination was expected
         */
        void setTerminationCause(const QString& terminationCause);

        /**
         * Return termination cause
         * @return termination cause if any was set, otherwise empty string
         */
        QString getTerminationCause() const;

        friend QDebug operator<<(QDebug dbg, const Platform* d);
        friend QDebug operator<<(QDebug dbg, const PlatformPtr& d);

    signals:
        /**
         * Emitted when there is available new message from device.
         * @param msg message from device
         */
        void messageReceived(strata::platform::PlatformMessage msg);

        /**
         * Emitted when message was written to device or some problem occured and message cannot be written.
         * @param rawMsg writen raw message to device
         * @param msgNum serial number of the sent message
         * @param errStr error string if message cannot be sent, empty (null) when everything is OK
         */
        void messageSent(QByteArray rawMsg, unsigned msgNum, QString errStr);

        /**
         * Emitted when error occured during communication on the serial port.
         * @param errCode error code
         * @param errStr error description
         */
        void deviceError(device::Device::ErrorCode errCode, QString errStr);

        /**
         * Emitted when device communication channel was opened.
         */
        void opened();

        /**
         * Emitted when device communication channel is about to be closed.
         */
        void aboutToClose();

        /**
         * Emitted when device communication channel was closed.
         */
        void closed();

        /**
         * Emitted when device is about to be erased from maps and no more operations shall be executed.
         */
        void terminated();

        /**
         * Emitted when device was identified using Identify operation.
         * @param isRecognized true if successfully recognized, otherwise false
         * @param inBootloader true if platform is in bootloader mode, otherwise false
         */
        void recognized(bool isRecognized, bool inBootloader);

        /**
         * Emitted when device receives 'platform Id changed' notification.
         */
        void platformIdChanged();

        /**
         * Emitted when device receives 'bootloader active' notification.
         */
        void bootloaderActive();

    private slots:
        void openedHandler();
        void messageReceivedHandler(QByteArray rawMsg);
        void messageSentHandler(QByteArray rawMsg, unsigned msgNum, QString errStr);
        void deviceErrorHandler(device::Device::ErrorCode errCode, QString errStr);

    private:
      // *** functions used by friend classes BasePlatformOperation and BasePlatformCommand:
        /**
         * Sets bootloader and/or application version.
         * @note Does not changes property if parameter is nullptr.
         * @param bootloaderVer bootloader version
         * @param bootloaderVer bootloader version
         */
        void setVersions(const char* bootloaderVer, const char* applicationVer);

        /**
         * Sets or clears (if parameter is nullptr) the provided properties.
         * @param name application name
         * @param platformId platform Id
         * @param classId class Id
         * @param type controller type
         */
        void setProperties(const char* name, const char* platformId, const char* classId, ControllerType type);

        /**
         * Sets or clears (if parameter is nullptr) the provided assisted properties.
         * @param platformId assisted platform Id
         * @param classId assisted class Id
         * @param fwClassId assisted firmware class Id
         */
        void setAssistedProperties(const char* platformId, const char* classId, const char* fwClassId);

        /**
         * Configures bootloader mode.
         * @param inBootloaderMode true if bootloader mode is active, otherwise false
         */
        void setBootloaderMode(bool inBootloaderMode);

        /**
         * Get bootloader mode property.
         * @note Before calling bootloaderMode(), commands get_firmware_info and request_platform_id must be called.
         * @return bootloader mode (device property)
         */
        bool bootloaderMode();

        /**
         * Sets API version property.
         * @param apiVersion API version
         */
        void setApiVersion(ApiVersion apiVersion);

        /**
         * Lock device with specified lock Id, so that only selected operation can use it
         * @param lockId lock Id
         * @return true if succesfully locked, otherwise false
         */
        bool lockDeviceForOperation(quintptr lockId);

        /**
         * Unlock device previously locked with specified lock Id
         * @param lockId lock Id
         */
        void unlockDevice(quintptr lockId);

        /**
         * Send message to device using the specified lock Id (internal).
         * Emits messageSent() signal.
         * @param message message to be written to device
         * @param lockId lock Id
         * @return serial number of the sent message
         */
        unsigned sendMessage(const QByteArray& message, quintptr lockId);

        /**
         * Sets flag if device was recognized and emits 'recognized()' signal.
         * @param isRecognized if the device was properly recognized
         */
        void setRecognized(bool isRecognized);
      // *** functions used by friend classes (end)

        /**
         * Stop reconnection timer if active.
         */
        void abortReconnect();

    protected:
        device::DevicePtr device_;

        // Mutex for protect access to operationLock_.
        QMutex operationMutex_;
        // If some operation (identification, flashing firmware, ...) is running, device should be locked
        // for other operations or sending messages. Device can be locked only by PlatformOperations class.
        // Address of PlatformOperations class instance is used as value of operationLock_. 0 means unlocked.
        quintptr operationLock_;

    private:
        QTimer reconnectTimer_;

        QReadWriteLock propertiesLock_;  // Lock for protect access to device properties.

        bool bootloaderMode_;
        bool isRecognized_;
        PlatformState platformState_;
        ApiVersion apiVersion_;
        ControllerType controllerType_;
        QString bootloaderVer_;
        QString applicationVer_;
        QString name_;
        QString platformId_;
        QString classId_;
        QString controllerPlatformId_;
        QString controllerClassId_;
        QString firmwareClassId_;
        QString terminationCause_;

        static const rapidjson::SchemaDocument platformIdChangedSchema_;
        static const rapidjson::SchemaDocument bootloaderActiveSchema_;
    };

}  // namespace
