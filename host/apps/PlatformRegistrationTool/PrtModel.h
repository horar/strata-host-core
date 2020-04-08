#ifndef PRTMODEL_H
#define PRTMODEL_H

#include <BoardManager.h>
#include <QObject>

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

signals:
    void boardReady(int deviceId);
    void boardDisconnected(int deviceId);
    void deviceCountChanged();

private slots:
    void boardReadyHandler(int deviceId, bool recognized);
    void boardDisconnectedHandler(int deviceId);

private:
    strata::BoardManager boardManager_;
    QList<strata::SerialDevicePtr> platformList_;
};

#endif  // PRTMODEL_H
