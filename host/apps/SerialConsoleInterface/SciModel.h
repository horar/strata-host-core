#ifndef SCIMODEL_H
#define SCIMODEL_H

#include "BoardsController.h"

#include <PlatformManager.h>

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
    Q_INVOKABLE QString urlToPath(const QUrl &url);
    Q_INVOKABLE bool isFile(const QString &file);

    BoardsController* boardController();

signals:
    void notify(QString connectionId, QString message);
    void programDeviceDone(QString connectionId, bool status);

private slots:
    void programDeviceDoneHandler(const QString& connectionId, bool status);

private:
    BoardsController boardController_;
};

#endif  // SCIMODEL_H
