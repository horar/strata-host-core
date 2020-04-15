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
         * The Result enum for finished() signal.
         */
        enum class Result {
            Ok,
            Error,
            Timeout,
            Cancelled
        };
        Q_ENUM(Result)

        /*!
         * Flasher constructor.
         * \param device device which will be used by Flasher
         * \param firmwareFilename path to firmware file
         */
        Flasher(const SerialDevicePtr& device, const QString& firmwareFilename);

        /*!
         * Flasher destructor.
         */
        ~Flasher();

        /*!
         * Flash firmware.
         * \param startApplication if set to true start application after flashing
         */
        void flash(bool startApplication = true);

        /*!
         * Cancel flash firmware operation.
         */
        void cancel();

        friend QDebug operator<<(QDebug dbg, const Flasher* f);

    signals:
        /*!
         * This signal is emitted when Flasher finishes.
         * \param result result of flash operation
         * \param errorString error description if result is Error
         */
        void finished(Result result, QString errorString);

        /*!
         * This signal is emitted during firmware flashing.
         * \param chunk chunk number which was flashed
         * \param total total count of firmware chunks
         */
        void flashProgress(int chunk, int total);

    private slots:
        void handleOperationFinished(int operation, int data);
        void handleOperationError(QString errStr);

    private:
        void handleFlashFirmware(int lastFlashedChunk);
        void finish(Result result, QString errStr = QString());

        SerialDevicePtr device_;

        QFile fwFile_;

        std::unique_ptr<DeviceOperations> operation_;

        uint deviceId_;

        int chunkNumber_;
        int chunkCount_;
        int chunkProgress_;

        bool startApp_;
};

}  // namespace

#endif
