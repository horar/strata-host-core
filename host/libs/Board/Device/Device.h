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

    enum class DeviceProperties {
        Name,
        BootloaderVer,
        ApplicationVer,
        PlatformId,
        ClassId,
        ControllerPlatformId,
        ControllerClassId,
        FirmwareClassId
    };

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
            SerialDevice
        };

        enum class ApiVersion {
            Unknown,
            v1_0,
            v2_0
        };

        enum class ControllerType {
            Embedded = 0x01,
            Assisted = 0x02
        };

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

        /**
         * Get property.
         * @param property value from enum DeviceProperties
         * @return QString filled with value of required property
         */
        virtual QString property(DeviceProperties property) final;

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
         * Get version of device API.
         * @return API version of device
         */
        virtual ApiVersion apiVersion() final;

        /**
         * Get device controller type (embedded, assisted).
         * @return controller type of device
         */
        virtual ControllerType controllerType() final;

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
        virtual void setVersions(const char* bootloaderVer, const char* applicationVer) final;
        virtual void setProperties(const char* name, const char* platformId, const char* classId, ControllerType type) final;
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
