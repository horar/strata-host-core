#include "PlatformIdentificationTest.h"

using strata::BoardManager;
using strata::device::DevicePtr;
using strata::device::DeviceProperties;

PlatformIdentificationTest::PlatformIdentificationTest(QObject *parent)
    : QObject(parent),
      testDeviceId_{0},
      testTimeout_(this),
      currentBinaryFileIndex_{0},
      binaryFileNameList_(),
      testSummaryList_(),
      testFailed_{false}
{
    connect(this, &PlatformIdentificationTest::setState, this, &PlatformIdentificationTest::stateChangedHandler);

    connect(&jlinkConnector_, &SGJLinkConnector::checkConnectionProcessFinished, this, &PlatformIdentificationTest::checkJLinkDeviceConnectionHandler);
    connect(&jlinkConnector_, &SGJLinkConnector::programBoardProcessFinished, this, &PlatformIdentificationTest::flashCompletedHandler);

    testTimeout_.setInterval(TEST_TIMEOUT);
    testTimeout_.setSingleShot(true);
    connect(&testTimeout_, &QTimer::timeout, this, &PlatformIdentificationTest::testTimeoutHandler);
}

void PlatformIdentificationTest::enableBoardManagerSignals(bool enable) {
    if (enable) {
        connect(&boardManager_, &BoardManager::boardReady, this, &PlatformIdentificationTest::newConnectionHandler);
        connect(&boardManager_, &BoardManager::boardDisconnected, this, &PlatformIdentificationTest::closeConnectionHandler);
    } else {
        disconnect(&boardManager_, &BoardManager::boardReady, this, &PlatformIdentificationTest::newConnectionHandler);
        disconnect(&boardManager_, &BoardManager::boardDisconnected, this, &PlatformIdentificationTest::closeConnectionHandler);
    }
}

bool PlatformIdentificationTest::init(const QString& jlinkExePath, const QString& binariesPath) {
    boardManager_.init(false);

    if (parseBinaryFileList(binariesPath) == false) {
        return false;
    }

    if (QFile::exists(jlinkExePath)) { 
        jlinkConnector_.setExePath(jlinkExePath);
        jlinkConnector_.setEraseBeforeProgram(true);
        // check if there is a JLinkConnected. need to connect the signals to get the result, this
        // is async process!
        if (!jlinkConnector_.checkConnectionRequested()) {
            std::cerr << "Failed to check if a JLink is connected." << std::endl;
            return false;
        }
    } else {
        std::cerr << "Invalid JLinkExe file path." << std::endl;
        return false;
    }

    return true;
}

void PlatformIdentificationTest::start() {
    std::cout << "Starting the test..." << std::endl;
    setState(PlatfortestState_::StartTest);
}

void PlatformIdentificationTest::checkJLinkDeviceConnectionHandler(bool exitedNormally, bool connected) {
    testTimeout_.stop();
    if (exitedNormally && connected) {
        std::cout << "JLink device is connected" << std::endl;
        setState(PlatfortestState_::FlashingPlatform);
    } 
    else {
        std::cerr << "Error connecting to JLink device" << std::endl;
        setState(PlatfortestState_::TestFinished);
    }
}

bool PlatformIdentificationTest::parseBinaryFileList(const QString& binariesPath) {
    QDir binariesDirectory(binariesPath);
    binaryFileNameList_ = binariesDirectory.entryList({"*.bin"}, QDir::Files);
    absloutePathToBinaries_ = binariesDirectory.absolutePath();

    if (binaryFileNameList_.empty()) {
        std::cerr << "No .bin files were found in " << absloutePathToBinaries_.toStdString() << std::endl;
        return false;
    }

    std::cout << binaryFileNameList_.count() << " .bin files were found in " << absloutePathToBinaries_.toStdString() << std::endl;
    for (const auto &fileName : binaryFileNameList_) {
        std::cout << fileName.toStdString() << std::endl;
    }

    return true;
}

void PlatformIdentificationTest::newConnectionHandler(int deviceId, bool recognized) {
    testTimeout_.stop();
    std::cout << "new board connected deviceId=" << deviceId << std::endl;
    std::cout << "board identified = " << recognized << std::endl;  // This flag is not enough!
    testDeviceId_ = deviceId;
    enableBoardManagerSignals(false);
    identifyPlatform(recognized);
}

void PlatformIdentificationTest::closeConnectionHandler(int deviceId) {
    std::cout << "board disconnected deviceId=" << deviceId << std::endl;
}

void PlatformIdentificationTest::flashCompletedHandler(bool exitedNormally) {
    // on success go to reconnect state
    testTimeout_.stop();
    std::cout << "flash is done" << std::endl;
    if (exitedNormally) {
        std::cout << "Platform was flashed successfully" << std::endl;
        enableBoardManagerSignals(true);
        setState(PlatfortestState_::ConnectingToPlatform);
    } else {
        std::cerr << "Failed to flash the platform. Aborting..." << std::endl;
        testFailed_ = true;
        setState(PlatfortestState_::TestFinished);
    }
}

void PlatformIdentificationTest::identifyPlatform(bool deviceRecognized) {
    DevicePtr testDevice = boardManager_.device(testDeviceId_);
    // determine if the test passed or not
    bool testPassed = false;
    
    // if device not recognized, doesn't have name, or doesn't have class id then it fails.
    if ( deviceRecognized == false
         || testDevice->property(DeviceProperties::classId).isEmpty()
         || testDevice->property(DeviceProperties::verboseName).isEmpty()) {
        testPassed = false;
    } else {
        testPassed = true;
    }

    if (testDevice != nullptr) {
        std::cout << "bin name: " << binaryFileNameList_[currentBinaryFileIndex_].toStdString() << std::endl;
        std::cout << "class id: " << testDevice->property(DeviceProperties::classId).toStdString() << std::endl;
        std::cout << "device name: " << testDevice->property(DeviceProperties::deviceName).toStdString() << std::endl;
        std::cout << "platform id: " << testDevice->property(DeviceProperties::platformId).toStdString() << std::endl;
        std::cout << "verbose name: " << testDevice->property(DeviceProperties::verboseName).toStdString() << std::endl;
        std::cout << "bootloader version: " << testDevice->property(DeviceProperties::bootloaderVer).toStdString() << std::endl;
        std::cout << "application version: " << testDevice->property(DeviceProperties::applicationVer).toStdString() << std::endl;

        // Append to the test summary list
        testSummaryList_.push_back({
                                       binaryFileNameList_[currentBinaryFileIndex_],
                                       testDevice->property(DeviceProperties::deviceName),
                                       testDevice->property(DeviceProperties::verboseName),
                                       testDevice->property(DeviceProperties::classId),
                                       testDevice->property(DeviceProperties::platformId),
                                       testDevice->property(DeviceProperties::bootloaderVer),
                                       testDevice->property(DeviceProperties::applicationVer),
                                       deviceRecognized,
                                       testPassed
                                   });
    } 
    else {
        std::cerr << "TestDevicePtr is null. Aborting..." << std::endl;
        testFailed_ = true;
        setState(PlatfortestState_::TestFinished);
    }

    // Move to the next file, or finish the test
    currentBinaryFileIndex_++;
    if (currentBinaryFileIndex_ < binaryFileNameList_.count()) {
        setState(PlatfortestState_::FlashingPlatform);
    } else {
        setState(PlatfortestState_::TestFinished);
    }
}

void PlatformIdentificationTest::connectToPlatform() {
    std::cout << "Connecting to platform" << std::endl;
    if (testDeviceId_ == 0) {
        // get the connected devices and set testDeviceId_
        auto connectedDevicesList = boardManager_.readyDeviceIds();
        if (connectedDevicesList.empty()) {
            std::cerr << "No connected devices. Aborting..." << std::endl;
            testFailed_ = true;
            setState(PlatfortestState_::TestFinished);
        } else {
            testDeviceId_ = connectedDevicesList.front();
        }
    }
    boardManager_.reconnect(testDeviceId_);
}

void PlatformIdentificationTest::flashPlatform(const QString& binaryFileName) {
    std::cout << "*****************************************************************" << std::endl;
    std::cout << "Test #" << currentBinaryFileIndex_ + 1 << " out of "
              << binaryFileNameList_.count() << std::endl;
    std::cout << "bin file: " << binaryFileName.toStdString() << std::endl;
    std::cout << "flashing platform..." << std::endl;

    // Use SGJLinkConnector to flash a the platform
    jlinkConnector_.programBoardRequested(binaryFileName);
}

void PlatformIdentificationTest::printSummary() {
    std::cout << "#####################################################################" << std::endl;
    std::cout << "########################### Test Summary ############################" << std::endl;
    std::cout << "#####################################################################" << std::endl;

    // check how many test failed. and print them
    int failedTestsCount = 0;
    QStringList failedTestsNames;

    for (const auto &testCase : testSummaryList_) {
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
        if (testCase.testPassed == false) {
            failedTestsCount++;
            failedTestsNames.push_back(testCase.fileName);
        }

        std::cout << "+----------------------------------------------------------------+" << std::endl;
    }
    std::cout << "Total tests: " << binaryFileNameList_.count() << std::endl;
    std::cout << "Passed: " << testSummaryList_.size() - failedTestsCount << std::endl;

    // tests failed and tests that were not performed.
    std::cerr << "Failed: " << failedTestsCount + (binaryFileNameList_.count() - testSummaryList_.size()) << std::endl;

    // if there are failed tests, list their names.
    if (failedTestsCount > 0) {
        testFailed_ = true;
        std::cerr << "Failed tests:" << std::endl;
        for (const auto &fileName : failedTestsNames) {
            std::cerr << "\t" << fileName.toStdString() << std::endl;
        }
    }

    std::cout << "#####################################################################" << std::endl;
}

void PlatformIdentificationTest::testTimeoutHandler() {
    std::cerr << "Test Timeout. Aborting..." << std::endl;
    testFailed_ = true;
    setState(PlatfortestState_::TestFinished);
}

void PlatformIdentificationTest::stateChangedHandler(PlatfortestState_ newState) {
    testState_ = newState;

    switch (testState_) {
        case PlatfortestState_::FlashingPlatform:
            flashPlatform(QDir(absloutePathToBinaries_).filePath(binaryFileNameList_[currentBinaryFileIndex_]));
            testTimeout_.start();
            break;

        case PlatfortestState_::ConnectingToPlatform:
            connectToPlatform();
            testTimeout_.start();
            break;

        case PlatfortestState_::TestFinished:
            printSummary();
            emit testDone(testFailed_);
            break;

        case PlatfortestState_::StartTest:
            testTimeout_.start();  // timeout until the JLink is connected.
            break;
    }
}
