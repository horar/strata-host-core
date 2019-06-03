#include "SgJLinkConnector.h"
#include "logging/LoggingQtCategories.h"

#include <QRegularExpression>

SgJLinkConnector::SgJLinkConnector(QObject *parent)
    : QObject(parent), process_(nullptr), configFile_(nullptr)
{
}

SgJLinkConnector::~SgJLinkConnector()
{
}

bool SgJLinkConnector::flashBoardRequested(const QString &binaryPath, bool eraseFirst)
{
    qCInfo(logCategorySci)
            << "binaryPath=" <<binaryPath
            << "eraseFirst=" << eraseFirst;

    QString cmd;
    cmd += QString("device %1\n").arg("EFM32GG380F1024");
    cmd += QString("si %1\n").arg("SWD");
    cmd += QString("speed %1\n").arg("4000");
    if (eraseFirst) {
        cmd += QString("erase\n");
    }

    if (!binaryPath.isEmpty()) {
        cmd += QString("loadbin %1, 0\n").arg(binaryPath);
    }

    cmd += QString("r\n");
    cmd += QString("go\n");
    cmd += QString("exit\n");

    return processRequest(cmd);
}

bool SgJLinkConnector::isBoardConnected()
{
    if (exePath_.isEmpty()) {
        qCWarning(logCategorySci) << "exePath is empty";
        return false;
    }

    QString cmd;
    cmd += QString("st\n");
    cmd += QString("exit\n");

    QTemporaryFile configFile;

    if (!configFile.open()) {
        qCWarning(logCategorySci) << "cannot open config file";
        return false;
    }

    QTextStream out(&configFile);
    out << cmd;
    out.flush();

    QStringList arguments;
    arguments << "-CommanderScript" << configFile.fileName();

    QProcess process;
    process.start(exePath_, arguments);
    if (process.waitForFinished(500)) {
        QRegularExpression re("(?<=^VTref=)[0-9]*.?[0-9]*(?=V$)");
        re.setPatternOptions(QRegularExpression::MultilineOption);
        QByteArray data = process.readAllStandardOutput();
        QRegularExpressionMatch match = re.match(data);
        if (match.hasMatch()) {
            if (match.captured(0).toFloat() > 0.01f) {
                return true;
            }
        }
    } else {
        qCWarning(logCategorySci) << "process did not finish";
        process.close();
    }

    return false;
}

QString SgJLinkConnector::exePath()
{
    return exePath_;
}

void SgJLinkConnector::setExePath(const QString &exePath)
{
    if (exePath_ != exePath) {
        exePath_ = exePath;
        emit exePathChanged();
    }
}

void SgJLinkConnector::finishedHandler(int exitCode, QProcess::ExitStatus exitStatus)
{
    qCInfo(logCategorySci)
            << "exitCode=" << exitCode
            << "exitStatus=" << exitStatus;

    finishFlashProcess(exitCode == 0 && exitStatus == QProcess::NormalExit);
}

void SgJLinkConnector::errorOccurredHandler(QProcess::ProcessError error)
{
    qCInfo(logCategorySci) << error;

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

    emit notify(errorStr);

    finishFlashProcess(false);
}

bool SgJLinkConnector::processRequest(const QString &cmd)
{
    if (exePath_.isEmpty()) {
        qCWarning(logCategorySci) << "exePath is empty";
        return false;
    }

    if (!process_.isNull()) {
        qCWarning(logCategorySci) << "process already in progress";
        return false;
    }

    configFile_ = new QTemporaryFile(this);

    if (!configFile_->open()) {
        qCWarning(logCategorySci) << "cannot open config file";
        delete configFile_;
        return false;
    }

    QTextStream out(configFile_);
    QStringList arguments;

    out << cmd;
    out.flush();

    arguments << "-CommanderScript" << configFile_->fileName() << "-ExitOnError" << "1";

    process_ = new QProcess(this);

    connect(process_, qOverload<int, QProcess::ExitStatus>(&QProcess::finished),
            this, &SgJLinkConnector::finishedHandler);

    connect(process_, &QProcess::errorOccurred,
            this, &SgJLinkConnector::errorOccurredHandler);

    qCInfo(logCategorySci) << "let's run" << exePath_ << arguments;
    emit notify(QString("Starting JLink process: %1\n").arg(exePath_));

    process_->start(exePath_, arguments);

    return true;
}

void SgJLinkConnector::finishFlashProcess(bool exitedNormally)
{
    qCInfo(logCategorySci) << "exitedNormally=" << exitedNormally;

    QByteArray output = process_->readAllStandardOutput();
    qCInfo(logCategorySci).noquote() << "output:"<< endl << output;

    process_->deleteLater();
    configFile_->deleteLater();

    emit boardFlashFinished(exitedNormally);
}
