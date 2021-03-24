#ifndef PLATFORMIDENTIFICATIONTEST_H
#define PLATFORMIDENTIFICATIONTEST_H

#include <QDir>
#include <QObject>

#include <PlatformManager.h>
#include <SGJLinkConnector.h>
#include <Device.h>

#include <iostream>

class PlatformIdentificationTest : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(PlatformIdentificationTest)

public:
    explicit PlatformIdentificationTest(QObject *parent = nullptr);
    bool init(const QString& jlinkExePath, const QString& binariesPath);
    void start();

private:
    enum class PlatfortestState_ {
        FlashingPlatform,
        ConnectingToPlatform,
        TestFinished,
        StartTest
    };

signals:
    void setState(PlatfortestState_ newState);
    void testDone(int exitStatus);

private slots:
    void newConnectionHandler(const QByteArray& deviceId, bool recognized);
    void closeConnectionHandler(const QByteArray& deviceId);
    void stateChangedHandler(PlatfortestState_ newState);
    void checkJLinkDeviceConnectionHandler(bool exitedNormally, bool connected);
    void flashCompletedHandler(bool exitedNormally);
    void testTimeoutHandler();

private:
    struct TestCase {
        QString fileName;
        QString deviceName;
        QString verboseName;
        QString classId;
        QString platformId;
        QString bootloaderVersion;
        QString applicationVersion;
        bool deviceRecognized;
        bool testPassed;
    };

    void flashPlatform(const QString& binaryFileName);
    void connectToPlatform();
    void identifyPlatform(bool deviceRecognized);
    bool parseBinaryFileList(const QString& binariesPath);
    void printSummary();
    void enableBoardManagerSignals(bool enable);

    strata::BoardManager boardManager_;
    PlatfortestState_ testState_;
    QByteArray testDeviceId_;
    SGJLinkConnector jlinkConnector_;

    const int TEST_TIMEOUT = 15000;
    QTimer testTimeout_;
    QString absloutePathToBinaries_;
    int currentBinaryFileIndex_;
    QStringList binaryFileNameList_;
    QList<TestCase> testSummaryList_;
    bool testFailed_;
};

#endif  // PLATFORMIDENTIFICATIONTEST_H
