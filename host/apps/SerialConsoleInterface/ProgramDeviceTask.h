#include <QObject>
#include <QRunnable>

#include <Flasher.h>

class ProgramDeviceTask : public QObject, public QRunnable
{
    Q_OBJECT
public:
    ProgramDeviceTask(spyglass::PlatformConnectionShPtr connection, const QString &firmwarePath);
    void run() override;

signals:
    void taskDone(QString connectionId, bool status);
    void notify(QString connectionId, QString message);

private:
    spyglass::PlatformConnectionShPtr connection_;
    QString firmwarePath_;
};
