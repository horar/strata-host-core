#ifndef DEVICE_H_
#define DEVICE_H_

#include <memory>

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QMutex>
#include <QReadWriteLock>

namespace strata::device {
    namespace command {
        class BaseDeviceCommand;
    }
    namespace operation {
        class BaseDeviceOperation;
    }
}

namespace strata::device {

    class Device;

    typedef std::shared_ptr<Device> DevicePtr;

    class Device : public QObject
    {
        Q_OBJECT
        Q_DISABLE_COPY(Device)

    friend class strata::device::operation::BaseDeviceOperation;
    friend class strata::device::command::BaseDeviceCommand;

    public:
        /**
        * The ErrorCode enum for deviceError() signal.
        */
        enum class ErrorCode {
            NoError = 0,
            UndefinedError,
            DeviceBusy,
            SendMessageError,
            // values from QSerialPort::SerialPortError:
            SP_DeviceNotFoundError = 101,
            SP_PermissionError,
            SP_OpenError,
            SP_ParityError,
            SP_FramingError,
            SP_BreakConditionError,
            SP_WriteError,
            SP_ReadError,
            SP_ResourceError,
            SP_UnsupportedOperationError,
            SP_UnknownError,
            SP_TimeoutError,
            SP_NotOpenError
        };
        Q_ENUM(ErrorCode)

        /**
        * The Type enum to recognize device type.
        */
        enum class Type {
            SerialDevice,
            MockDevice
        };
        Q_ENUM(Type)

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
         * Device constructor
         * @param deviceId device ID
         * @param name device name
         * @param type device type (value form Type enum)
         */
        Device(const int deviceId, const QString& name, const Type type);

        /**
         * Device destructor
         */
        virtual ~Device();

        /**
         * Open device communication channel.
         * @return true if device was opened, otherwise false
         */
        virtual bool open() = 0;

        /**
         * Close device communication channel.
         */
        virtual void close() = 0;

        /**
         * Send message to  device. Emits deviceError() signal in case of failure.
         * @param msg message to be written to device
         * @return true if message can be sent, otherwise false
         */
        virtual bool sendMessage(const QByteArray msg) = 0;

        // *** Device properties (start) ***

        /**
         * Get name property.
         * @return name (device property)
         */
        virtual QString name() final;

        /**
         * Get bootloader version property.
         * @return bootloader version (device property)
         */
        virtual QString bootloaderVer() final;

        /**
         * Get application version property.
         * @return application version (device property)
         */
        virtual QString applicationVer() final;

        /**
         * Get platform ID property.
         * @return platform ID (device property)
         */
        virtual QString platformId() final;

        /**
         * Check if class ID property is set.
         * @return true if class ID is set (true is returned also if class ID is empty string)
         */
        virtual bool hasClassId() final;

        /**
         * Get class ID property.
         * @return class ID (device property)
         */
        virtual QString classId() final;

        /**
         * Get controller platform ID property.
         * @return controller platform ID (device property)
         */
        virtual QString controllerPlatformId() final;

        /**
         * Get controller class ID property.
         * @return controller class ID (device property)
         */
        virtual QString controllerClassId() final;

        /**
         * Get firmware class ID property.
         * @return firmware class ID (device property)
         */
        virtual QString firmwareClassId() final;

        /**
         * Get API version property.
         * @return API version (device property)
         */
        virtual ApiVersion apiVersion() final;

        /**
         * Get controller type property.
         * @return controller type (device property)
         */
        virtual ControllerType controllerType() final;

        // *** Device properties (end) ***

        /**
         * Get device ID.
         * @return Device ID
         */
        virtual int deviceId() const final;

        /**
         * Get device name given by system (e.g. COM3)
         * @return Device name
         */
        virtual const QString deviceName() const final;

        /**
         * Get device type.
         * @return Type of device
         */
        virtual Type deviceType() const final;

        /**
         * Check if controller is connected to platform (dongle is connected to board).
         * This method must be called after Identify operation finishes or after signal
         * boardInfoChanged is received from BoardManager.
         * @return true if controller is connected to platform, false otherwise
         */
        virtual bool isControllerConnectedToPlatform() final;

        friend QDebug operator<<(QDebug dbg, const Device* d);
        friend QDebug operator<<(QDebug dbg, const DevicePtr& d);

    signals:
        /**
         * Emitted when there is available new message from device.
         * @param msg message from device
         */
        void msgFromDevice(QByteArray msg);

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
        void deviceError(ErrorCode errCode, QString msg);

    private:
      // *** functions used by friend classes BaseDeviceOperation and BaseDeviceCommand:
        // Does not change property if parameter is nullptr.
        virtual void setVersions(const char* bootloaderVer, const char* applicationVer) final;
        // Clears property if parameter is nullptr.
        virtual void setProperties(const char* name, const char* platformId, const char* classId, ControllerType type) final;
        // Clears property if parameter is nullptr.
        virtual void setAssistedProperties(const char* platformId, const char* classId, const char* fwClassId) final;
        virtual bool lockDeviceForOperation(quintptr lockId) final;
        virtual void unlockDevice(quintptr lockId) final;
        virtual bool sendMessage(const QByteArray msg, quintptr lockId) = 0;
        virtual void setBootloaderMode(bool inBootloaderMode) final;
        // Before calling bootloaderMode(), commands get_firmware_info and request_platform_id must be called.
        virtual bool bootloaderMode() final;
        virtual void setApiVersion(ApiVersion apiVersion) final;
      // ***

    protected:
        const int deviceId_;
        const QString deviceName_;  // name given by system (e.g. COM3)
        const Type deviceType_;

        // Mutex for protect access to operationLock_.
        QMutex operationMutex_;
        // If some operation (identification, flashing firmware, ...) is running, device should be locked
        // for other operations or sending messages. Device can be locked only by DeviceOperations class.
        // Address of DeviceOperations class instance is used as value of operationLock_. 0 means unlocked.
        quintptr operationLock_;

    private:
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

#endif
