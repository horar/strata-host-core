#ifndef PRTMODEL_H
#define PRTMODEL_H

#include <BoardManager.h>
#include <FlasherConnector.h>

#include <QObject>
#include <QPointer>

class PrtModel : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(PrtModel)

    Q_PROPERTY(int deviceCount READ deviceCount NOTIFY deviceCountChanged)

public:
    explicit PrtModel(QObject *parent = nullptr);
    virtual ~PrtModel();

    int deviceCount() const;

    Q_INVOKABLE QString deviceFirmwareVersion() const;
    Q_INVOKABLE QString deviceFirmwareVerboseName() const;
    Q_INVOKABLE QString programDevice(QString filePath);

signals:
    void boardReady(int deviceId);
    void boardDisconnected(int deviceId);
    void deviceCountChanged();
    void flasherProgress(
            strata::FlasherConnector::Operation operation,
            strata::FlasherConnector::State state,
            QString errorString);

    void flasherFinished(strata::FlasherConnector::Result result);

private slots:
    void boardReadyHandler(int deviceId, bool recognized);
    void boardDisconnectedHandler(int deviceId);
    void flasherFinishedHandler(strata::FlasherConnector::Result result);

private:
    strata::BoardManager boardManager_;
    QList<strata::device::DevicePtr> platformList_;
    QPointer<strata::FlasherConnector> flasherConnector_;
};

#endif  // PRTMODEL_H
