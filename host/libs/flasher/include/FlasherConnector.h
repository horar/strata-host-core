#ifndef FLASHERCONNECTOR_H
#define FLASHERCONNECTOR_H

#include <QObject>
#include <QMutex>
#include <QWaitCondition>
#include <QMap>

#include <Flasher.h>
#include <PlatformConnection.h>

class Flasher;

class FlasherWorker : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(FlasherWorker)

public:
    FlasherWorker(spyglass::PlatformConnectionShPtr connection, const QString &firmwarePath, QObject *parent = nullptr);
    ~FlasherWorker() = default;

    /**
     * Stop request, must be called from other thread
     */
    void stop();

public slots:
    void process();

signals:
    void finished();

    void taskDone(QString connectionId, bool status);
    void notify(QString connectionId, QString message);

private:

    /**
     * Cancel check callback method
     * @return returns true when cancel was requested otherwise false
     */
    bool isCancelRequested();

private:
    spyglass::PlatformConnectionShPtr connection_;
    QString firmwarePath_;

    QAtomicInt stopFlag_;
};

//////////////////////////////////////////////////////////////////////////////////////

class FlasherConnector : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(FlasherConnector)

public:
    FlasherConnector(QObject *parent = nullptr);
    ~FlasherConnector();

    /**
     * Starts flashing task in the background
     * @param connection
     * @param firmwarePath
     */
    bool start(spyglass::PlatformConnectionShPtr connection, const QString &firmwarePath);

    /**
     * Stops flashing of given connection id and waits for finish
     */
    void stop(const QString& connectionId);

    /**
     * Stops all flashing and waits for finish
     */
    void stopAll();

signals:
    void taskDone(QString connectionId, bool status);
    void notify(QString connectionId, QString message);

private:
    QMutex connectionToWorkerMutex_;
    QMap<QString, FlasherWorker*> connectionToWorker_;

};

#endif // FLASHERCONNECTOR_H
