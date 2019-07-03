#ifndef FLASHERCONNECTOR_H
#define FLASHERCONNECTOR_H

#include <QObject>
#include <QRunnable>

#include <Flasher.h>
#include <PlatformConnection.h>

class FlasherTask : public QObject, public QRunnable
{
    Q_OBJECT
public:
    FlasherTask(spyglass::PlatformConnectionShPtr connection, const QString &firmwarePath);

    void run() override;

signals:
    void taskDone(QString connectionId, bool status);
    void notify(QString connectionId, QString message);

private:
    spyglass::PlatformConnectionShPtr connection_;
    QString firmwarePath_;
};

class FlasherConnector: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(FlasherConnector)

public:
    FlasherConnector(QObject *parent = nullptr);

    void start(spyglass::PlatformConnectionShPtr connection, const QString &firmwarePath);

signals:
    void taskDone(QString connectionId, bool status);
    void notify(QString connectionId, QString message);
};

#endif // FLASHERCONNECTOR_H
