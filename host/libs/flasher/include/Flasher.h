#ifndef FLASHER_H_
#define FLASHER_H_

#include <QObject>
#include <QFile>

#include <memory>

#include <SerialDevice.h>

namespace strata {

class DeviceOperations;

class Flasher : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(Flasher)

    public:
        Flasher(std::shared_ptr<strata::SerialDevice> device, const QString& firmwareFilename);
        ~Flasher();

        void flash(bool startApplication = true);

        friend QDebug operator<<(QDebug dbg, const Flasher* f);

    signals:
        void finished(bool success);

    private slots:
        void handleFlashFirmware(int lastFlashedChunk);
        void handleStartApp();
        void handleTimeout();
        void handleError(QString msg);
        void handleCancel();

    private:
        void finish(bool success);

        SerialDeviceShPtr device_;

        QFile fw_file_;

        std::unique_ptr<DeviceOperations> operation_;

        uint device_id_;

        int chunk_number_;
        int chunk_count_;

        bool start_app_;
};

}  // namespace

#endif
