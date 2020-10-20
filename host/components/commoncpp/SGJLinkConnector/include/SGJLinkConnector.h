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
    Q_PROPERTY(bool eraseBeforeProgram READ eraseBeforeProgram WRITE setEraseBeforeProgram NOTIFY eraseBeforeProgramChanged)

public:
    explicit SGJLinkConnector(QObject *parent = nullptr);
    virtual ~SGJLinkConnector();

    enum ProcessType {
        PROCESS_NO_PROCESS,
        PROCESS_CHECK_CONNECTION,
        PROCESS_PROGRAM,
    };
    Q_ENUM(ProcessType)

    Q_INVOKABLE bool checkConnectionRequested();
    Q_INVOKABLE bool programBoardRequested(const QString &binaryPath);

    QString exePath() const;
    void setExePath(const QString &exePath);
    bool eraseBeforeProgram() const;
    void setEraseBeforeProgram(bool eraseBeforeProgram);

signals:
    void checkConnectionProcessFinished(bool exitedNormally, bool connected);
    void programBoardProcessFinished(bool exitedNormally);
    void exePathChanged();
    void eraseBeforeProgramChanged();

private slots:
    void finishedHandler(int exitCode, QProcess::ExitStatus exitStatus);
    void errorOccurredHandler(QProcess::ProcessError error);

private:
    QPointer<QProcess> process_;
    QPointer<QFile> configFile_;
    QString exePath_;
    ProcessType activeProcessType_;
    bool eraseBeforeProgram_ = false;

    bool processRequest(const QString &cmd, ProcessType type);
    void finishProcess(bool exitedNormally);
    bool parseStatusOutput(const QString &output);
};

#endif  // SGJLINKCONNECTOR
