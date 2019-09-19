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

bool SGJLinkConnector::flashBoardRequested(const QString &binaryPath, bool eraseFirst)
{
    qCInfo(logCategoryJLink)
            << "binaryPath=" <<binaryPath
            << "eraseFirst=" << eraseFirst;

    QString cmd;
    cmd += QString("exitonerror 1\n");
    cmd += QString("si %1\n").arg("SWD");
    cmd += QString("speed %1\n").arg("4000");

    if (eraseFirst) {
        cmd += QString("erase\n");
    }

    cmd += QString("loadbin \"%1\", 0x0\n").arg(binaryPath);
    cmd += QString("verifybin \"%1\", 0x0\n").arg(binaryPath);
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
    cmd += QString("exitonerror 1\n");
    cmd += QString("st\n");
    cmd += QString("exit\n");

    QFile configFile(QDir(QDir::tempPath()).filePath("boardcheck.jlink"));

    if (configFile.open(QIODevice::ReadWrite) == false) {
        qCWarning(logCategoryJLink) << "cannot open config file";
        return false;
    }

    QTextStream out(&configFile);
    out << cmd;
    out.flush();

    configFile.close();

    QStringList arguments;
    arguments << "-CommandFile" << QDir::toNativeSeparators(configFile.fileName());

    QProcess process;
    process.start(exePath_, arguments);

    bool hasMatch = false;
    if (process.waitForFinished(1500)) {
        QRegularExpression re("(?<=VTref=)[0-9]*.?[0-9]*(?=V)");
        re.setPatternOptions(QRegularExpression::MultilineOption);
        QByteArray data = process.readAllStandardOutput();
        qCDebug(logCategoryJLink) << "process finished" << data;
        QRegularExpressionMatch match = re.match(data);
        if (match.hasMatch()) {
            if (match.captured(0).toFloat() > 0.01f) {
                hasMatch = true;
            }
        }
    } else {
        qCWarning(logCategoryJLink) << "jlink process did not finish";
        process.close();
    }

    configFile.remove();

    return hasMatch;
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

    configFile_ = new QFile(QDir(QDir::tempPath()).filePath("boardflash.jlink"));

    if (configFile_->open(QIODevice::ReadWrite) == false) {
        qCWarning(logCategoryJLink) << "cannot open config file" << configFile_->fileName();
        delete configFile_;
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
    configFile_->remove();
    configFile_->deleteLater();

    emit processFinished(exitedNormally);
}
