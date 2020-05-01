#include "PlatformIdentificationTest.h"

PlatformIdentificationTest::PlatformIdentificationTest(QObject *parent)
    : QObject(parent),
      mTestDeviceId{0},
      mTestTimeout(this),
      mCurrentBinaryFileIndex{0},
      mBinaryFileNameList(),
      mTestSummaryList(),
      mTestFailed{false}
{
    // Connect private signals
    connect(this, &PlatformIdentificationTest::stateChanged, this, &PlatformIdentificationTest::onStateChanged);

    // Connect SGJLinkConnector signals
    connect(&mSGJLinkConnector, &SGJLinkConnector::checkConnectionProcessFinished, this, &PlatformIdentificationTest::onCheckJLinkDeviceConnection);
    connect(&mSGJLinkConnector, &SGJLinkConnector::flashBoardProcessFinished, this, &PlatformIdentificationTest::onFlashCompleted);

    // Set up the timeout
    mTestTimeout.setInterval(TEST_TIMEOUT);
    mTestTimeout.setSingleShot(true);
    connect(&mTestTimeout, &QTimer::timeout, this, &PlatformIdentificationTest::onTestTimeout);
}

void PlatformIdentificationTest::enableBoardManagerSignals(bool enable) {
    if (enable) {
        // Connect BoardManager signals
        connect(&mBoardManager, &strata::BoardManager::boardReady, this, &PlatformIdentificationTest::onNewConnection);
        connect(&mBoardManager, &strata::BoardManager::boardDisconnected, this, &PlatformIdentificationTest::onCloseConnection);
    } else {
        // Disconnect BoardManager signals
        disconnect(&mBoardManager, &strata::BoardManager::boardReady, this, &PlatformIdentificationTest::onNewConnection);
        disconnect(&mBoardManager, &strata::BoardManager::boardDisconnected, this, &PlatformIdentificationTest::onCloseConnection);
    }
}

bool PlatformIdentificationTest::init(QString jlinkExePath, QString binariesPath) {
    mBoardManager.init(false);

    // get a list of *.bin files found in the provided path
    if (!parseBinaryFileList(binariesPath)) {
        return false;
    }

    // set up SGJLinkConnector
    if (QFile::exists(jlinkExePath)) {  // check if the JLinkExe path is correct
        mSGJLinkConnector.setExePath(jlinkExePath);
        // check if there is a JLinkConnected. need to connect the signals to get the result, this
        // is async process!
        if (!mSGJLinkConnector.checkConnectionRequested()) {
            std::cout << "Failed to check if a JLink is connected." << std::endl;
            return false;
        }
    } 
    else {
        std::cout << "Invalid JLinkExe file path." << std::endl;
        return false;
    }

    return true;
}

void PlatformIdentificationTest::start() {
    // change the state to StartTest
    std::cout << "Starting the test..." << std::endl;
    stateChanged(PlatformTestState::StartTest);
}

void PlatformIdentificationTest::onCheckJLinkDeviceConnection(bool exitedNormally, bool connected) {
    mTestTimeout.stop();
    if (exitedNormally && connected) {
        std::cout << "JLink device is connected" << std::endl;
        stateChanged(PlatformTestState::FlashingPlatform);
    } 
    else {
        std::cout << "Error connecting to JLink device" << std::endl;
        stateChanged(PlatformTestState::TestFinished);
    }
}

bool PlatformIdentificationTest::parseBinaryFileList(QString binariesPath) {
    QDir binariesDirectory(binariesPath);
    mBinaryFileNameList = binariesDirectory.entryList({"*.bin"}, QDir::Files);
    mAbsloutePathToBinaries = binariesDirectory.absolutePath();

    // check if empty list
    if (mBinaryFileNameList.empty()) {
        std::cout << "No .bin files were found in " << mAbsloutePathToBinaries.toStdString() << std::endl;
        return false;
    }
    
    // print the file names
    std::cout << mBinaryFileNameList.count() << " .bin files were found in " << mAbsloutePathToBinaries.toStdString() << std::endl;
    for (const auto &fileName : mBinaryFileNameList) {
        std::cout << fileName.toStdString() << std::endl;
    }

    return true;
}

void PlatformIdentificationTest::onNewConnection(int deviceId, bool recognized) {
    mTestTimeout.stop();
    std::cout << "new board connected deviceId=" << deviceId << std::endl;
    std::cout << "board identified = " << recognized << std::endl;  // This flag is not enough!
    mTestDeviceId = deviceId;
    enableBoardManagerSignals(false);
    identifyPlatform(recognized);
}

void PlatformIdentificationTest::onCloseConnection(int deviceId) {
    std::cout << "board disconnected deviceId=" << deviceId << std::endl;
}

void PlatformIdentificationTest::onFlashCompleted(bool exitedNormally) {
    // on success go to reconnect state
    mTestTimeout.stop();
    std::cout << "flash is done" << std::endl;
    if (exitedNormally) {
        std::cout << "Platform was flashed successfully" << std::endl;
        enableBoardManagerSignals(true);
        stateChanged(PlatformTestState::ConnectingToPlatform);
    } else {
        std::cout << "Failed to flash the platform. Aborting..." << std::endl;
        mTestFailed = true;
        stateChanged(PlatformTestState::TestFinished);
    }
}

void PlatformIdentificationTest::identifyPlatform(bool deviceRecognized) {
    strata::SerialDevicePtr testDevice = mBoardManager.device(mTestDeviceId);
    // determine if the test passed or not
    bool testPassed = false;
    // if device not recognized, doesn't have name, or doesn't have class id then it fails.
    if (!deviceRecognized
            || testDevice->property(strata::DeviceProperties::classId).isEmpty()
            || testDevice->property(strata::DeviceProperties::verboseName).isEmpty()) {
        testPassed = false;
    } 
    else {
        testPassed = true;
    }

    if (testDevice != nullptr) {
        std::cout << "bin name: " << mBinaryFileNameList[mCurrentBinaryFileIndex].toStdString() << std::endl;
        std::cout << "class id: " << testDevice->property(strata::DeviceProperties::classId).toStdString() << std::endl;
        std::cout << "device name: " << testDevice->property(strata::DeviceProperties::deviceName).toStdString() << std::endl;
        std::cout << "platform id: " << testDevice->property(strata::DeviceProperties::platformId).toStdString() << std::endl;
        std::cout << "verbose name: " << testDevice->property(strata::DeviceProperties::verboseName).toStdString() << std::endl;
        std::cout << "bootloader version: " << testDevice->property(strata::DeviceProperties::bootloaderVer).toStdString() << std::endl;
        std::cout << "application version: " << testDevice->property(strata::DeviceProperties::applicationVer).toStdString() << std::endl;

        // Append to the test summary list
        mTestSummaryList.push_back({
                                        mBinaryFileNameList[mCurrentBinaryFileIndex],
                                        testDevice->property(strata::DeviceProperties::deviceName),
                                        testDevice->property(strata::DeviceProperties::verboseName),
                                        testDevice->property(strata::DeviceProperties::classId),
                                        testDevice->property(strata::DeviceProperties::platformId),
                                        testDevice->property(strata::DeviceProperties::bootloaderVer),
                                        testDevice->property(strata::DeviceProperties::applicationVer),
                                        deviceRecognized,
                                        testPassed
                                   });
    } 
    else {
        std::cout << "TestDevicePtr is null. Aborting..." << std::endl;
        mTestFailed = true;
        stateChanged(PlatformTestState::TestFinished);
    }

    // Move to the next file, or finish the test
    mCurrentBinaryFileIndex++;
    if (mCurrentBinaryFileIndex < mBinaryFileNameList.count()) {
        stateChanged(PlatformTestState::FlashingPlatform);
    } 
    else {
        stateChanged(PlatformTestState::TestFinished);
    }
}

void PlatformIdentificationTest::connectToPlatform() {
    std::cout << "Connecting to platform" << std::endl;
    if (mTestDeviceId == 0) {
        // get the connected devices and set mTestDeviceId
        auto connectedDevicesList = mBoardManager.readyDeviceIds();
        if (connectedDevicesList.empty()) {
            std::cout << "No connected devices. Aborting..." << std::endl;
            mTestFailed = true;
            stateChanged(PlatformTestState::TestFinished);
        } 
        else {
            mTestDeviceId = connectedDevicesList.front();
        }
    }
    mBoardManager.reconnect(mTestDeviceId);
}

void PlatformIdentificationTest::flashPlatform(QString binaryFileName) {
    std::cout << "*****************************************************************" << std::endl;
    std::cout << "Test #" << mCurrentBinaryFileIndex + 1 << " out of "
              << mBinaryFileNameList.count() << std::endl;
    std::cout << "bin file: " << binaryFileName.toStdString() << std::endl;
    std::cout << "flashing platform..." << std::endl;

    // Use SGJLinkConnector to flash a the platform
    mSGJLinkConnector.flashBoardRequested(binaryFileName, true);
}

void PlatformIdentificationTest::printSummary() {
    std::cout << "#####################################################################" << std::endl;
    std::cout << "########################### Test Summary ############################" << std::endl;
    std::cout << "#####################################################################" << std::endl;

    // check how many test failed. and print them
    int failedTestsCount = 0;
    QStringList failedTestsNames;

    for (const auto &testCase : mTestSummaryList) {
        std::cout << "file name: " << testCase.fileName.toStdString() << std::endl;
        std::cout << "device name: " << testCase.deviceName.toStdString() << std::endl;
        std::cout << "verbose name: " << testCase.verboseName.toStdString() << std::endl;
        std::cout << "class id: " << testCase.classId.toStdString() << std::endl;
        std::cout << "platform id: " << testCase.platformId.toStdString() << std::endl;
        std::cout << "bootloader version: " << testCase.bootloaderVersion.toStdString() << std::endl;
        std::cout << "application version: " << testCase.applicationVersion.toStdString() << std::endl;
        std::cout << "device recognized: " << testCase.deviceRecognized << std::endl;
        std::cout << "test result: " << testCase.testPassed << std::endl;

        // if the test failed add the name of the .bin file to the list.
        if (!testCase.testPassed) {
            failedTestsCount++;
            failedTestsNames.push_back(testCase.fileName);
        }

        std::cout << "+----------------------------------------------------------------+" << std::endl;
    }
    std::cout << "Total tests: " << mBinaryFileNameList.count() << std::endl;
    std::cout << "Passed: " << mTestSummaryList.size() - failedTestsCount << std::endl;

    // tests failed and tests that were not performed.
    std::cout << "Failed: " << failedTestsCount + (mBinaryFileNameList.count() - mTestSummaryList.size()) << std::endl;

    // if there are failed tests, list their names.
    if (failedTestsCount > 0) {
        mTestFailed = true;
        std::cout << "Failed tests:" << std::endl;
        for (const auto &fileName : failedTestsNames) {
            std::cout << "\t" << fileName.toStdString() << std::endl;
        }
    }

    std::cout << "#####################################################################" << std::endl;
}

void PlatformIdentificationTest::onTestTimeout() {
    std::cout << "Test Timeout. Aborting..." << std::endl;
    mTestFailed = true;
    stateChanged(PlatformTestState::TestFinished);
}

void PlatformIdentificationTest::onStateChanged(PlatformTestState newState) {
    mTestState = newState;

    switch (mTestState) {
        case PlatformTestState::FlashingPlatform:
            flashPlatform(mAbsloutePathToBinaries + "/" + mBinaryFileNameList[mCurrentBinaryFileIndex]);
            mTestTimeout.start();
            break;

        case PlatformTestState::ConnectingToPlatform:
            connectToPlatform();
            mTestTimeout.start();
            break;

        case PlatformTestState::TestFinished:
            printSummary();
            emit testDone(mTestFailed);
            break;

        case PlatformTestState::StartTest:
            mTestTimeout.start();  // timeout until the JLink is connected.
            break;
    }
}
