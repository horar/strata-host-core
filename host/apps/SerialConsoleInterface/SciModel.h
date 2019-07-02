#ifndef SCIMODEL_H
#define SCIMODEL_H

#include <FlasherConnector.h>
#include <PlatformManager.h>
#include <BoardsController.h>

#include <QObject>

class SciModel : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SciModel)

    Q_PROPERTY(BoardsController* boardController READ boardController CONSTANT)
public:
    explicit SciModel(QObject *parent = nullptr);
    virtual ~SciModel();

    Q_INVOKABLE void programDevice(const QString &connectionId, const QString &firmwarePath);
    Q_INVOKABLE void stopProgramming();

    BoardsController* boardController();

signals:
    void notify(QString connectionId, QString message);
    void programDeviceDone(QString connectionId, bool status);

private slots:
    void programDeviceDoneHandler(const QString& connectionId, bool status);

private:
    BoardsController boardController_;
    FlasherConnector flasherConnector_;
};

#endif  // SCIMODEL_H
