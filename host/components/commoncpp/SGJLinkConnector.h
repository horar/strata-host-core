#ifndef SGJLINKCONNECTOR
#define SGJLINKCONNECTOR

#include <QObject>
#include <QPointer>
#include <QProcess>
#include <QTemporaryFile>

class SGJLinkConnector : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SGJLinkConnector)

    Q_PROPERTY(QString exePath READ exePath WRITE setExePath NOTIFY exePathChanged)

public:
    explicit SGJLinkConnector(QObject *parent = nullptr);
    virtual ~SGJLinkConnector();

    Q_INVOKABLE bool flashBoardRequested(const QString &binaryPath, bool eraseFirst = false);
    Q_INVOKABLE bool isBoardConnected();

    QString exePath();
    void setExePath(const QString &exePath);

signals:
    void notify(QString message);
    void processFinished(bool status);
    void exePathChanged();

private slots:
    void finishedHandler(int exitCode, QProcess::ExitStatus exitStatus);
    void errorOccurredHandler(QProcess::ProcessError error);

private:
    QPointer<QProcess> process_;
    QPointer<QTemporaryFile> configFile_;
    QString exePath_;

    bool processRequest(const QString &cmd);
    void finishFlashProcess(bool exitedNormally);
};

#endif  // SGJLINKCONNECTOR
