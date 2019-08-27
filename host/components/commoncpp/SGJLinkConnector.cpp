#include "SGJLinkConnector.h"
#include "logging/LoggingQtCategories.h"

#include <QRegularExpression>
#include <QTextStream>

SGJLinkConnector::SGJLinkConnector(QObject *parent)
    : QObject(parent), process_(nullptr), configFile_(nullptr)
{
}

SGJLinkConnector::~SGJLinkConnector()
{
}

bool SGJLinkConnector::flashBoardRequested(const QString &binaryPath, bool eraseFirst)
{
    qCInfo(logCategoryJLink)
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

bool SGJLinkConnector::isBoardConnected()
{
    if (exePath_.isEmpty()) {
        qCWarning(logCategoryJLink) << "exePath is empty";
        return false;
    }

    QString cmd;
    cmd += QString("st\n");
    cmd += QString("exit\n");

    QTemporaryFile configFile;

    if (!configFile.open()) {
        qCWarning(logCategoryJLink) << "cannot open config file";
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
        qCWarning(logCategoryJLink) << "process did not finish";
        process.close();
    }

    return false;
}

QString SGJLinkConnector::exePath()
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

void SGJLinkConnector::finishedHandler(int exitCode, QProcess::ExitStatus exitStatus)
{
    qCInfo(logCategoryJLink)
            << "exitCode=" << exitCode
            << "exitStatus=" << exitStatus;

    finishFlashProcess(exitCode == 0 && exitStatus == QProcess::NormalExit);
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

    emit notify(errorStr);

    finishFlashProcess(false);
}

bool SGJLinkConnector::processRequest(const QString &cmd)
{
    if (exePath_.isEmpty()) {
        qCWarning(logCategoryJLink) << "exePath is empty";
        return false;
    }

    if (!process_.isNull()) {
        qCWarning(logCategoryJLink) << "process already in progress";
        return false;
    }

    configFile_ = new QTemporaryFile(this);

    if (!configFile_->open()) {
        qCWarning(logCategoryJLink) << "cannot open config file";
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
            this, &SGJLinkConnector::finishedHandler);

    connect(process_, &QProcess::errorOccurred,
            this, &SGJLinkConnector::errorOccurredHandler);

    qCInfo(logCategoryJLink) << "let's run" << exePath_ << arguments;
    emit notify(QString("Starting JLink process: %1\n").arg(exePath_));

    process_->start(exePath_, arguments);

    return true;
}

void SGJLinkConnector::finishFlashProcess(bool exitedNormally)
{
    qCInfo(logCategoryJLink) << "exitedNormally=" << exitedNormally;

    QByteArray output = process_->readAllStandardOutput();
    qCInfo(logCategoryJLink).noquote() << "output:"<< endl << output;

    process_->deleteLater();
    configFile_->deleteLater();

    emit processFinished(exitedNormally);
}
