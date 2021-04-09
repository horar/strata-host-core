#pragma once

#include <DeviceNew.h>

#include <memory>

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QMutex>
#include <QReadWriteLock>
#include <QDateTime>
#include <QTimer>

namespace strata::platform {

    namespace command {
        class BasePlatformCommand;
    }
    namespace operation {
        class BasePlatformOperation;
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
        enum class PlatformState {
            AttemptingToOpen,
            Open,
            ClosedPartially,
            Closed
        };
        Q_ENUM(PlatformState)

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

        /**
         * Platform constructor
         * @param device pointer
         */
        explicit Platform(const device::DeviceNewPtr& device) noexcept(false);

        /**
         * Platform destructor
         */
        ~Platform();

        /**
         * Open device communication channel.
         * Emits opened() signal in case of success.
         * Emits deviceError(DeviceFailedToOpen) signal in case of failure.
         * @param retryTimestamp timeout between re-attempts to open the device (in case of failure)
         */
        void open(const QDateTime &retryTimestamp);

        /**
         * Close device communication channel.
         * Emits closed() signal upon completion.
         * @param waitTimestamp how long to remain in closed state before re-attempting to open the device
         * @param retryTimestamp timeout between re-attempts to open the device (in case of failure)
         */
        void close(const QDateTime &waitTimestamp, const QDateTime &retryTimestamp);

        /**
         * Send message to device.
         * Emits messageSent() signal in case of success.
         * Emits deviceError() signal in case of failure.
         * @param msg message to be written to device
         */
        void sendMessage(const QByteArray msg);

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
        device::DeviceNew::Type deviceType() const;

        /**
         * Check if controller is connected to platform (dongle is connected to board).
         * This method must be called after Identify operation finishes or after signal
         * boardInfoChanged is received from PlatformManager.
         * @return true if controller is connected to platform, false otherwise
         */
        bool isControllerConnectedToPlatform();

        friend QDebug operator<<(QDebug dbg, const Platform* d);
        friend QDebug operator<<(QDebug dbg, const PlatformPtr& d);

    signals:
        /**
         * Emitted when there is available new message from device.
         * @param msg message from device
         */
        void messageReceived(QByteArray msg);

        /**
         * Emitted when message was written to device.
         * @param msg writen message to device
         */
        void messageSent(QByteArray msg);

        /**
         * Emitted when error occured during communication on the serial port.
         * @param errCode error code
         * @param msg error description
         */
        void deviceError(device::DeviceNew::ErrorCode errCode, QString msg);

        /**
         * Emitted when device communication channel was open.
         */
        void opened();

        /**
         * Emitted when device communication channel was closed.
         */
        void closed();

        /**
         * Emitted when device was identified using Identify operation.
         */
        void recognized();

        /**
         * Emitted when device receives platform Id changed message.
         */
        void platformIdChanged();

    private slots:
        void messageReceivedHandler(QByteArray msg);
        void messageSentHandler(QByteArray msg);
        void deviceErrorHandler(device::DeviceNew::ErrorCode errCode, QString msg);

    private:
      // *** functions used by friend classes BasePlatformOperation and BasePlatformCommand:
        // Does not change property if parameter is nullptr.
        void setVersions(const char* bootloaderVer, const char* applicationVer);
        // Clears property if parameter is nullptr.
        void setProperties(const char* name, const char* platformId, const char* classId, ControllerType type);
        // Clears property if parameter is nullptr.
        void setAssistedProperties(const char* platformId, const char* classId, const char* fwClassId);
        bool lockDeviceForOperation(quintptr lockId);
        void unlockDevice(quintptr lockId);
        bool sendMessage(const QByteArray msg, quintptr lockId);
        void setBootloaderMode(bool inBootloaderMode);
        // Before calling bootloaderMode(), commands get_firmware_info and request_platform_id must be called.
        bool bootloaderMode();
        void setApiVersion(ApiVersion apiVersion);
      // ***

    protected:
        void changeState(PlatformState state) noexcept(false);
        void timerExpired();

        device::DeviceNewPtr device_;
        PlatformState state_ = PlatformState::Closed;

        // Mutex for protect access to operationLock_.
        QMutex operationMutex_;
        // If some operation (identification, flashing firmware, ...) is running, device should be locked
        // for other operations or sending messages. Device can be locked only by PlatformOperations class.
        // Address of PlatformOperations class instance is used as value of operationLock_. 0 means unlocked.
        quintptr operationLock_;

    private:
        QTimer reconnectTimer_;
        QDateTime waitTimestamp_;
        QDateTime retryTimestamp_;

        QReadWriteLock properiesLock_;  // Lock for protect access to device properties.

        bool bootloaderMode_;
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
    };

}  // namespace
