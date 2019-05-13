#ifndef SCIMODEL_H
#define SCIMODEL_H

#include "BoardsController.h"

#include <Flasher.h>
#include <PlatformManager.h>

#include <QObject>
#include <QRunnable>

class ProgramDeviceTask : public QObject, public QRunnable
{
    Q_OBJECT
public:
    ProgramDeviceTask(spyglass::PlatformConnection *connection, const QString &firmwarePath);
    void run() override;

signals:
    void taskDone(spyglass::PlatformConnection *connector, bool status);
    void notify(QString connectionId, QString message);

private:
    spyglass::PlatformConnection *connection_;
    QString firmwarePath_;
};

class SciModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(BoardsController* boardController READ boardController CONSTANT)

public:
    explicit SciModel(QObject *parent = nullptr);
    virtual ~SciModel();

    Q_INVOKABLE void programDevice(const QString &connectionId, const QString &firmwarePath);
    Q_INVOKABLE QString urlToPath(const QUrl &url);
    Q_INVOKABLE bool isFile(const QString &file);

    BoardsController* boardController();

signals:
    void notify(QString connectionId, QString message);
    void programDeviceDone(QString connectionId, bool status);

private slots:
    void programDeviceDoneHandler(spyglass::PlatformConnection *connection, bool status);

private:
    Q_DISABLE_COPY(SciModel)

    BoardsController boardController_;
};

#endif  // SCIMODEL_H
