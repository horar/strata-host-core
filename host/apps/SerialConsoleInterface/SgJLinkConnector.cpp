#include "SgJLinkConnector.h"

#include <QDebug>
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
    qDebug() << "SgJLinkConnector::flashBoardRequested() binary " << binaryPath;

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
        qDebug() << "SgJLinkConnector::isBoardConnected() exePath is empty";
        return false;
    }

    QString cmd;
    cmd += QString("st\n");
    cmd += QString("exit\n");

    QTemporaryFile configFile;

    if (!configFile.open()) {
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
        qDebug() << "SgJLinkConnector::isBoardConnected() process did not finish";
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
    qDebug() << "SgJLinkConnector::finishedHandler()" << exitCode << exitStatus;

    finishFlashProcess(exitCode == 0 && exitStatus == QProcess::NormalExit);
}

void SgJLinkConnector::errorOccurredHandler(QProcess::ProcessError error)
{
    qDebug() << "SgJLinkConnector::errorOccuredHandler()" << error;

    QString errorStr;

    if (error == QProcess::FailedToStart) {
        errorStr = "JLink process failed to start.\n";
    } else if (error == QProcess::Crashed) {
        errorStr = "JLink process crashed.\n";
    } else if (error == QProcess::Timedout) {
        errorStr = "JLink process time out error.\n";
    } else if (error == QProcess::WriteError) {
        errorStr = "JLink process write error.\n";
    } else if (error == QProcess::ReadError) {
        errorStr = "JLink process read error.\n";
    } else if (error == QProcess::UnknownError) {
        errorStr = "JLink process unknown error.\n";
    }

    emit notify(errorStr);

    finishFlashProcess(false);
}

void SgJLinkConnector::readStandardOutputHandler()
{
    QByteArray output = process_->readAllStandardOutput();
    emit notify(output);
}

bool SgJLinkConnector::processRequest(const QString &cmd)
{
    if (exePath_.isEmpty()) {
        qDebug() << "SgJLinkConnector::processRequest() exePath is empty";
        return false;
    }

    if (!process_.isNull()) {
        qDebug() << "SgJLinkConnector::processRequest() process already in progress";
        return false;
    }

    configFile_ = new QTemporaryFile(this);

    if (!configFile_->open()) {
        delete configFile_;
        return false;
    }

    QTextStream out(configFile_);
    QStringList arguments;

    out << cmd;
    out.flush();

    arguments << "-CommanderScript" << configFile_->fileName() << "-ExitOnError" << "1";

    process_ = new QProcess(this);

    connect(process_, SIGNAL(finished(int, QProcess::ExitStatus)),
            this, SLOT(finishedHandler(int, QProcess::ExitStatus)));

    connect(process_, SIGNAL(errorOccurred(QProcess::ProcessError)),
            this, SLOT(errorOccurredHandler(QProcess::ProcessError)));

    connect(process_, SIGNAL(readyReadStandardOutput()),
            this, SLOT(readStandardOutputHandler()));

    qDebug() << "SgJLinkConnector::flashBoardRequested() let's run" << exePath_ << arguments;
    emit notify(QString("Starting JLink process: %1\n").arg(exePath_));

    process_->start(exePath_, arguments);

    return true;
}

void SgJLinkConnector::finishFlashProcess(bool exitedNormally)
{
    qDebug() << "SgJLinkConnector::finishFlashProcess()" << exitedNormally;

    process_->deleteLater();
    configFile_->deleteLater();

    emit boardFlashFinished(exitedNormally);
}
