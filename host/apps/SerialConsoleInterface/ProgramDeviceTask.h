#include <QObject>
#include <QRunnable>

#include <Flasher.h>

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
