#ifndef PLATFORMIDENTIFICATIONTEST_H
#define PLATFORMIDENTIFICATIONTEST_H

#include <QDir>
#include <QObject>

#include <BoardManager.h>
#include <SGJLinkConnector.h>
#include <SerialDevice.h>

#include <iostream>

class PlatformIdentificationTest : public QObject
{
    Q_OBJECT
public:
    explicit PlatformIdentificationTest(QObject *parent = nullptr);
    bool init(const QString& jlinkExePath, const QString& binariesPath);
    void start();

private:
    // State machine
    enum class PlatformTestState {
        FlashingPlatform = 1,
        ConnectingToPlatform = 2,
        TestFinished = 3,
        StartTest = 4
    };

signals:
    void stateChanged(PlatformTestState newState);
    void testDone(int exitStatus);  // signal to exit the app

private slots:
    void onNewConnection(int deviceId, bool recognized);
    void onCloseConnection(int deviceId);
    void onStateChanged(PlatformTestState newState);
    void onCheckJLinkDeviceConnection(bool exitedNormally, bool connected);
    void onFlashCompleted(bool exitedNormally);
    void onTestTimeout();

private:
    // struct definition to store test results
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

    // Private functions
    void flashPlatform(const QString& binaryFileName);
    void connectToPlatform();
    void identifyPlatform(bool deviceRecognized);
    bool parseBinaryFileList(const QString& binariesPath);
    void printSummary();
    void enableBoardManagerSignals(bool enable);

    // Private members
    strata::BoardManager mBoardManager;
    PlatformTestState mTestState;
    int mTestDeviceId;
    SGJLinkConnector mSGJLinkConnector;

    const int TEST_TIMEOUT = 15000;  // 15s
    QTimer mTestTimeout;
    QString mAbsloutePathToBinaries;
    int mCurrentBinaryFileIndex;
    QStringList mBinaryFileNameList;
    std::vector<TestCase> mTestSummaryList;
    bool mTestFailed;
};

#endif  // PLATFORMIDENTIFICATIONTEST_H
