#include "SGJLinkConnector.h"
#include "logging/LoggingQtCategories.h"

#include <QRegularExpression>
#include <QTextStream>
#include <QDir>

SGJLinkConnector::SGJLinkConnector(QObject *parent)
    : QObject(parent), process_(nullptr), configFile_(nullptr)
{
}

SGJLinkConnector::~SGJLinkConnector()
{
}

bool SGJLinkConnector::checkConnectionRequested()
{
    if (exePath_.isEmpty()) {
        qCWarning(logCategoryJLink) << "exePath is empty";
        return false;
    }

    QString cmd;

    cmd += QString("exitonerror 1\n");
    cmd += QString("st\n");
    cmd += QString("exit\n");

    return processRequest(cmd, PROCESS_CHECK_CONNECTION);
}

bool SGJLinkConnector::programBoardRequested(const QString &binaryPath)
{
    qCInfo(logCategoryJLink)
            << "binaryPath=" <<binaryPath
            << "eraseBeforeProgram=" << eraseBeforeProgram_;

    QString cmd;
    cmd += QString("exitonerror 1\n");
    cmd += QString("exec DisableInfoWinFlashDL\n");
    cmd += QString("si %1\n").arg("SWD");
    cmd += QString("speed %1\n").arg("4000");

    if (eraseBeforeProgram_) {
        cmd += QString("erase\n");
    }

    cmd += QString("loadbin \"%1\", 0x0\n").arg(binaryPath);
    cmd += QString("verifybin \"%1\", 0x0\n").arg(binaryPath);
    cmd += QString("r\n");
    cmd += QString("go\n");
    cmd += QString("exit\n");

    return processRequest(cmd, PROCESS_PROGRAM);
}

QString SGJLinkConnector::exePath() const
{
    return exePath_;
}

void SGJLinkConnector::setExePath(const QString &exePath)
{
    if (exePath_ != exePath) {
        exePath_ = exePath;
        emit exePathChanged();
    }
}

bool SGJLinkConnector::eraseBeforeProgram() const
{
    return eraseBeforeProgram_;
}

void SGJLinkConnector::setEraseBeforeProgram(bool eraseBeforeProgram)
{
    if (eraseBeforeProgram_ != eraseBeforeProgram) {
        eraseBeforeProgram_ = eraseBeforeProgram;
        emit eraseBeforeProgramChanged();
    }
}

void SGJLinkConnector::finishedHandler(int exitCode, QProcess::ExitStatus exitStatus)
{
    qCInfo(logCategoryJLink)
            << "exitCode=" << exitCode
            << "exitStatus=" << exitStatus;

    finishProcess(exitCode == 0 && exitStatus == QProcess::NormalExit);
}

void SGJLinkConnector::errorOccurredHandler(QProcess::ProcessError error)
{
    QString errorStr;

    switch (error) {
    case QProcess::FailedToStart:
        errorStr = "JLink process failed to start.\n";
        break;
    case QProcess::Crashed:
        errorStr = "JLink process crashed.\n";
        break;
    case QProcess::Timedout:
        errorStr = "JLink process time out error.\n";
        break;
    case QProcess::WriteError:
        errorStr = "JLink process write error.\n";
        break;
    case QProcess::ReadError:
        errorStr = "JLink process read error.\n";
        break;
    default:
        errorStr = "JLink process unknown error.\n";
    }

    qCWarning(logCategoryJLink) << error << errorStr;

    finishProcess(false);
}

bool SGJLinkConnector::processRequest(const QString &cmd, ProcessType type)
{
    if (exePath_.isEmpty()) {
        qCCritical(logCategoryJLink) << "exePath is empty";
        activeProcessType_ = PROCESS_NO_PROCESS;
        return false;
    }

    if (!process_.isNull()) {
        qCWarning(logCategoryJLink) << "process already in progress";
        activeProcessType_ = PROCESS_NO_PROCESS;
        return false;
    }

    configFile_ = new QFile(QDir(QDir::tempPath()).filePath("jlinkconnector.jlink"));

    if (configFile_->open(QIODevice::ReadWrite) == false) {
        qCCritical(logCategoryJLink) << "cannot open config file" << configFile_->fileName() << configFile_->errorString();
        delete configFile_;
        activeProcessType_ = PROCESS_NO_PROCESS;
        return false;
    }

    QTextStream out(configFile_);
    QStringList arguments;

    out << cmd;
    out.flush();

    configFile_->close();

    arguments << "-Device" << "EFM32GG380F1024"
              << "-CommandFile" << QDir::toNativeSeparators(configFile_->fileName());

    process_ = new QProcess(this);

    connect(process_, qOverload<int, QProcess::ExitStatus>(&QProcess::finished),
            this, &SGJLinkConnector::finishedHandler);

    connect(process_, &QProcess::errorOccurred,
            this, &SGJLinkConnector::errorOccurredHandler);

    qCInfo(logCategoryJLink) << "let's run"
                             << type
                             << exePath_
                             << arguments;

    process_->start(exePath_, arguments);
    activeProcessType_ = type;

    return true;
}

void SGJLinkConnector::finishProcess(bool exitedNormally)
{
    qCDebug(logCategoryJLink) << "exitedNormally=" << exitedNormally;

    QByteArray output = process_->readAllStandardOutput();
    qCDebug(logCategoryJLink).noquote() << "output:"<< endl << output;

    ProcessType type = activeProcessType_;
    activeProcessType_ = PROCESS_NO_PROCESS;
    process_->deleteLater();
    process_.clear();
    configFile_->remove();
    configFile_->deleteLater();

    if (type == PROCESS_CHECK_CONNECTION) {
        bool isConnected = parseStatusOutput(output);
        emit checkConnectionProcessFinished(exitedNormally, isConnected);
    } else if(type == PROCESS_PROGRAM) {
        emit programBoardProcessFinished(exitedNormally);
    }
}

bool SGJLinkConnector::parseStatusOutput(const QString &output)
{
    QRegularExpression re("(?<=VTref=)[0-9]*.?[0-9]*(?=V)");
    re.setPatternOptions(QRegularExpression::MultilineOption);
    QRegularExpressionMatch match = re.match(output);
    if (match.hasMatch()) {
        if (match.captured(0).toFloat() > 0.01f) {
            return true;
        }
    }

    return false;
}
