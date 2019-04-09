#ifndef JLINKCONNECTOR
#define JLINKCONNECTOR

#include <QObject>
#include <QPointer>
#include <QProcess>
#include <QTemporaryFile>

class SgJLinkConnector : public QObject
{
    Q_OBJECT

public:
    explicit SgJLinkConnector(QObject *parent = nullptr);
    virtual ~SgJLinkConnector();

    Q_INVOKABLE bool flashBoardRequested(const QString &binaryPath, bool eraseFirst = false);

signals:
    void notify(QString message);
    void boardFlashFinished(bool success);

private slots:
    void finishedHandler(int exitCode, QProcess::ExitStatus exitStatus);
    void errorOccurredHandler(QProcess::ProcessError error);
    void readStandardOutputHandler();

private:
    Q_DISABLE_COPY(SgJLinkConnector)

    QPointer<QProcess> process_;
    QPointer<QTemporaryFile> configFile_;

    bool processRequest(const QString cmd);
    void finishFlashProcess(bool exitedNormally);
};

#endif  // JLINKCONNECTOR
