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
        /*!
         * Flasher constructor.
         * \param device device which will be used by Flasher
         * \param firmwareFilename path to firmware file
         */
        Flasher(SerialDeviceShPtr device, const QString& firmwareFilename);

        ~Flasher();

        /*!
         * Flash firmware.
         * \param startApplication if set to true start application after flashing
         */
        void flash(bool startApplication = true);

        friend QDebug operator<<(QDebug dbg, const Flasher* f);

    signals:
        /*!
         * This signal is emitted when Flasher finishes.
         * \param success true if firmware was flashed successfully, otherwise false
         */
        void finished(bool success);

    private slots:
        void handleOperationFinished(int operation, int data);
        void handleOperationError(QString msg);

    private:
        void handleFlashFirmware(int lastFlashedChunk);
        void finish(bool success);

        SerialDeviceShPtr device_;

        QFile fwFile_;

        std::unique_ptr<DeviceOperations> operation_;

        uint deviceId_;

        int chunkNumber_;
        int chunkCount_;

        bool startApp_;
};

}  // namespace

#endif
