#ifndef FLASHER_CONNECTOR_H_
#define FLASHER_CONNECTOR_H_

#include <memory>

#include <QObject>
#include <QString>

#include <SerialDevice.h>
#include <Flasher.h>

namespace strata {

class FlasherConnector : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(FlasherConnector)

public:
    /*!
     * FlasherConnector constructor.
     * \param device device which will be used by FlasherConnector
     * \param firmwareFilename path to firmware file
     */
    FlasherConnector(const SerialDevicePtr& device, const QString& firmwareFilename, QObject* parent = nullptr);

    /*!
     * FlasherConnector destructor.
     */
    ~FlasherConnector();

    /*!
     * Flash firmware.
     */
    void flash();

    /*!
     * Stop flash firmware operation.
     */
    void stop();

signals:
    /*!
     * This signal is emitted when FlasherConnector finishes.
     * \param result result of flash operation
     * \param errorString error description if result is Error, otherwise empty
     */
    void finished(Flasher::Result result, QString errorString);

    /*!
     * This signal is emitted during firmware flashing.
     * \param chunk number of firmware chunks which was flashed
     * \param total total count of firmware chunks
     */
    void flashProgress(int chunk, int total);

private:
    SerialDevicePtr device_;
    std::unique_ptr<Flasher> flasher_;
    const QString fileName_;
};

}  // namespace

#endif
