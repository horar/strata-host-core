#ifndef PLATFORMIDENTIFICATIONTEST_H
#define PLATFORMIDENTIFICATIONTEST_H

#include <QObject>
#include <QDir>

#include <BoardManager.h>
#include <SerialDevice.h>
#include <SGJLinkConnector.h>

#include <iostream>

class PlatformIdentificationTest : public QObject
{
    Q_OBJECT
public:
    explicit PlatformIdentificationTest(QObject *parent = nullptr);
    void init(QString jlinkExePath, QString binariesPath);
    void start();

private:
    // State machine
    enum class PlatformTestState {
        Init = 0,
        FlashinPlatform = 1,
        ConnectingToPlatform = 2,
        IdentifingPlatform = 3,
        TestFinished = 4,
        Idle = 5
    };

signals:
    void stateChanged(PlatformTestState newState);
    void testDone(int exitStatus); // signal to exit the app

private slots:
    void newConnection(int deviceId, bool recognized);
    void closeConnection(int deviceId);
    void onStateChanged(PlatformTestState newState);
    void onCheckJLinkDeviceConnection(bool exitedNormally, bool connected);
    void onFlashCompleted(bool exitedNormally);

private:
    // Private functions
    void flashPlatform();
    void connectToPlatform();
    void identifyPlatform();
    bool parseBinaryFileList(QString binariesPath);


    // Private members
    strata::BoardManager mBoardManager;
    PlatformTestState mTestState;
    int mTestDeviceId;
    SGJLinkConnector mSGJLinkConnector;

    QString mAbsloutePathToBinaries;
    int mCurrentBinaryFileIndex;
    QStringList mBinaryFileNameList;
};

#endif // PLATFORMIDENTIFICATIONTEST_H
