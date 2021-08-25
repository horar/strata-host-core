#include "SGJLinkConnector.h"
#include "logging/LoggingQtCategories.h"

#include <SGUtilsCpp.h>
#include <QRegularExpression>
#include <QTextStream>
#include <QDir>

SGJLinkConnector::SGJLinkConnector(QObject *parent)
    : QObject(parent),
      process_(nullptr),
      configFile_(nullptr)
{
}

SGJLinkConnector::~SGJLinkConnector()
{
    clearInternalBinary();
}

bool SGJLinkConnector::checkConnectionRequested()
{
    QString cmd;

    cmd += QString("exitonerror 1\n");
    cmd += QString("st\n");
    cmd += QString("exit\n");

    return processRequest(cmd, PROCESS_CHECK_CONNECTION);
}

bool SGJLinkConnector::programBoardRequested(const QString &binaryPath)
{
    if (device_.isEmpty()) {
        qCCritical(logCategoryJLink()) << "device is not set";
        return false;
    }

    if (speed_ <= 0) {
        qCCritical(logCategoryJLink()) << "speed is not valid";
        return false;
    }

    if (startAddress_ < 0) {
        qCCritical(logCategoryJLink()) << "start address is not valid";
        return false;
    }

    if (internalBinaryFilename_.isEmpty() == false) {
        qCCritical(logCategoryJLink) << "another operation in progress";
        return false;
    }

    /* This is to fix an issue on win where if binaryPath belongs to file created via QTemporaryFile,
       jlink.exe fails with "Failed to open file" */
    copyToInternalBinary(binaryPath);
    if (internalBinaryFilename_.isEmpty()) {
        qCCritical(logCategoryJLink) << "cannot create internal copy of binary file";
        return false;
    }

    QString cmd;
    cmd += QString("exitonerror 1\n");
    cmd += QString("exec DisableInfoWinFlashDL\n");
    cmd += QString("si %1\n").arg("SWD");
    cmd += QString("speed %1\n").arg(speed_);

    if (eraseBeforeProgram_) {
        cmd += QString("erase\n");
    }

    QString startAddressHex = SGUtilsCpp::toHex(startAddress_, 8);

    cmd += QString("loadbin \"%1\", %2\n").arg(internalBinaryFilename_). arg(startAddressHex);
    cmd += QString("verifybin \"%1\", %2\n").arg(internalBinaryFilename_).arg(startAddressHex);
    cmd += QString("r\n");
    cmd += QString("go\n");
    cmd += QString("exit\n");

    return processRequest(cmd, PROCESS_PROGRAM);
}

bool SGJLinkConnector::programBoardRequested(
        const QString &binaryPath,
        bool eraseBeforeProgram,
        QString device,
        int speed,
        int startAddress)
{
    setEraseBeforeProgram(eraseBeforeProgram);
    setDevice(device);
    setSpeed(speed);
    setStartAddress(startAddress);

    return programBoardRequested(binaryPath);
}

bool SGJLinkConnector::checkHostVersion()
{
    QString cmd;
    cmd += QString("exit\n");

    return processRequest(cmd, PROCESS_CHECK_HOST_VERSION);
}

QVariantMap SGJLinkConnector::latestOutputInfo()
{
    return latestOutputInfo_;
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

QString SGJLinkConnector::device() const
{
    return device_;
}

void SGJLinkConnector::setDevice(const QString &device)
{
    if (device_ != device) {
        device_ = device;
        emit deviceChanged();
    }
}

int SGJLinkConnector::speed() const
{
    return speed_;
}

void SGJLinkConnector::setSpeed(int speed)
{
    if (speed_ != speed) {
        speed_ = speed;
        emit speedChanged();
    }
}

int SGJLinkConnector::startAddress() const
{
    return startAddress_;
}

void SGJLinkConnector::setStartAddress(int startAddress)
{
    if (startAddress_ != startAddress) {
        startAddress_ = startAddress;
        emit startAddressChanged();
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
    latestRawOutput_.clear();
    latestOutputInfo_.clear();

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

    qCInfo(logCategoryJLink) << "command" << cmd;

    QTextStream out(configFile_);
    QStringList arguments;

    out << cmd;
    out.flush();

    configFile_->close();

    if (device_.isEmpty() == false) {
        arguments << "-Device" << device_;
    }

    arguments << "-CommandFile" << QDir::toNativeSeparators(configFile_->fileName());

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

    latestRawOutput_ = process_->readAllStandardOutput();
    qCDebug(logCategoryJLink).noquote() << "output:"<< endl << latestRawOutput_;

    if (exitedNormally) {
        parseOutput(activeProcessType_);
    }

    ProcessType type = activeProcessType_;
    activeProcessType_ = PROCESS_NO_PROCESS;
    process_->deleteLater();
    process_.clear();
    configFile_->remove();
    configFile_->deleteLater();

    if (type == PROCESS_CHECK_CONNECTION) {
        bool isConnected = false;
        if (exitedNormally) {
            float referenceVoltage = 0.0f;
             bool matched = parseReferenceVoltage(latestRawOutput_, referenceVoltage);
             isConnected = matched && referenceVoltage > 0.01f;
        }

        emit checkConnectionProcessFinished(exitedNormally, isConnected);
    } else if (type == PROCESS_PROGRAM) {
        clearInternalBinary();
        emit programBoardProcessFinished(exitedNormally);
    } else if (type == PROCESS_CHECK_HOST_VERSION) {
        emit checkHostVersionProcessFinished(exitedNormally);
    }
}

void SGJLinkConnector::parseOutput(SGJLinkConnector::ProcessType type)
{
    bool matched;
    QString version, date;

    latestOutputInfo_.clear();

    if (type == PROCESS_CHECK_CONNECTION || type == PROCESS_PROGRAM || type == PROCESS_CHECK_HOST_VERSION) {
        matched = parseCommanderVersion(latestRawOutput_, version, date);
        if (matched) {
            latestOutputInfo_.insert("commander_version", version);
            latestOutputInfo_.insert("commander_date", date);
        }

        matched = parseLibraryVersion(latestRawOutput_, version, date);
        if (matched) {
            latestOutputInfo_.insert("lib_version", version);
            latestOutputInfo_.insert("lib_date", date);
        }
    }

    if (type == PROCESS_CHECK_CONNECTION || type == PROCESS_PROGRAM) {
        matched = parseEmulatorFwVersion(latestRawOutput_, version, date);
        if (matched) {
            latestOutputInfo_.insert("emulator_fw_version", version);
            latestOutputInfo_.insert("emulator_fw_date", date);
        }
    }
}

bool SGJLinkConnector::parseReferenceVoltage(const QString &output, float &voltage)
{
    QRegularExpression re("(?<=^VTref=)[0-9]*.?[0-9]*(?=V)");
    re.setPatternOptions(QRegularExpression::MultilineOption | QRegularExpression::CaseInsensitiveOption);
    QRegularExpressionMatch match = re.match(output);

    if (match.hasMatch() == false) {
        qCWarning(logCategoryJLink()) << "reference voltage could not be determined";
        return false;
    }

    voltage = match.captured(0).toFloat();
    return true;
}

bool SGJLinkConnector::parseLibraryVersion(const QString &output, QString &version, QString &date)
{
    QRegularExpression re("(?<version>(?<=^dll version )[a-z\\.\\d_]+)[^a-z]+compiled (?<date>[a-z]{3}\\s+\\d{1,2}\\s+\\d\\d\\d\\d)\\s");
    re.setPatternOptions(QRegularExpression::MultilineOption | QRegularExpression::CaseInsensitiveOption);
    QRegularExpressionMatch match = re.match(output);

    if (match.hasMatch() == false) {
        qCWarning(logCategoryJLink()) << "library version could not be determined";
        return false;
    }

    version = match.captured("version");
    date = match.captured("date");
    return true;
}

bool SGJLinkConnector::parseCommanderVersion(const QString &output, QString &version, QString &date)
{
    QRegularExpression re("(?<version>(?<=^segger j-link commander )[a-z\\.\\d_]+)[^a-z]+compiled (?<date>[a-z]{3}\\s+\\d{1,2}\\s+\\d\\d\\d\\d)\\s");
    re.setPatternOptions(QRegularExpression::MultilineOption | QRegularExpression::CaseInsensitiveOption);
    QRegularExpressionMatch match = re.match(output);

    if (match.hasMatch() == false) {
        qCWarning(logCategoryJLink()) << "commander version could not be determined";
        return false;
    }

    version = match.captured("version");
    date = match.captured("date");
    return true;
}

bool SGJLinkConnector::parseEmulatorFwVersion(const QString &output, QString &version, QString &date)
{
    QRegularExpression re("(?<version>(?<=^firmware: ).*)[^a-z]compiled (?<date>[a-z]{3}\\s+\\d{1,2}\\s+\\d\\d\\d\\d)\\s");
    re.setPatternOptions(QRegularExpression::MultilineOption | QRegularExpression::CaseInsensitiveOption);
    QRegularExpressionMatch match = re.match(output);

    if (match.hasMatch() == false) {
        qCWarning(logCategoryJLink()) << "emulator fw version could not be determined";
        return false;
    }

    version = match.captured("version");
    date = match.captured("date");
    return true;
}

void SGJLinkConnector::copyToInternalBinary(const QString &src)
{
    QFileInfo srcInfo(src);
    QString defaultFilePath = QDir(QDir::tempPath()).filePath("jlink-connector-data." + srcInfo.completeSuffix());
    QFileInfo info(defaultFilePath);
    QString uniqueFilePath = defaultFilePath;

    int index = 1;
    while (QFileInfo::exists(uniqueFilePath)) {
        QString addition = "-" + QString::number(index);
        uniqueFilePath = defaultFilePath;
        uniqueFilePath.insert(uniqueFilePath.length() - info.completeSuffix().length() - 1, addition);
        ++index;
    }

    bool copied = QFile::copy(src, uniqueFilePath);
    if (copied == false) {
        qCWarning(logCategoryJLink) << "cannot copy file";
        return;
    }

    internalBinaryFilename_ = uniqueFilePath;
}

void SGJLinkConnector::clearInternalBinary()
{
    if (internalBinaryFilename_.isEmpty()) {
        return;
    }

    QFile internalBinary(internalBinaryFilename_);
    if (internalBinary.remove() == false) {
        qCCritical(logCategoryJLink)
                << "cannot remove internal binary"
                << internalBinary.fileName()
                << internalBinary.errorString();
    }
}
