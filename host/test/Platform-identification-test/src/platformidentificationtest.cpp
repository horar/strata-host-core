#include "platformidentificationtest.h"

PlatformIdentificationTest::PlatformIdentificationTest(QObject *parent) : QObject(parent)
{  
    // connect private signals
    connect(this, &PlatformIdentificationTest::stateChanged, this, &PlatformIdentificationTest::onStateChanged);

//    // connect BoardManager signals
//    // for this test, im interested in the following signals:
//    connect(&mBoardManager, &strata::BoardManager::boardReady, this, &PlatformIdentificationTest::newConnection);
//    connect(&mBoardManager, &strata::BoardManager::boardDisconnected, this, &PlatformIdentificationTest::closeConnection);

    // Connect SGJLinkConnector signals
    //connect(&mSGJLinkConnector, &SGJLinkConnector::checkConnectionRequested, this, &PlatformIdentificationTest::onCheckJLinkDeviceConnection);
    connect(&mSGJLinkConnector, &SGJLinkConnector::flashBoardProcessFinished, this, &PlatformIdentificationTest::onFlashCompleted);
}

void PlatformIdentificationTest::newConnection(int deviceId, bool recognized) {
    std::cout << "new board connected" << std::endl;
    std::cout << "board identified successfully=" << recognized << std::endl; // <-- not enough!
    mTestDeviceId = deviceId;
    stateChanged(PlatformTestState::IdentifingPlatform);
    // handle that the device is good or not,
    // mBoardManager.reconnect(deviceId);
}

void PlatformIdentificationTest::closeConnection(int deviceId) {
    std::cout << "board disconnected" << std::endl;
}

void PlatformIdentificationTest::onCheckJLinkDeviceConnection(bool exitedNormally, bool connected) {
    // set a flag that JLink is connected and ready to be used.
    if (exitedNormally && connected) {
        std::cout << "JLink device is connected" << std::endl;
    }
    else {
        std::cout << "Error connectign to JLink device" << std::endl;
    }
}

void PlatformIdentificationTest::onFlashCompleted(bool exitedNormally) {
    // on success go to reconnect state
    std::cout << "flash is done" << std::endl;
    if(exitedNormally) {
        std::cout << "Platform was flashed successfully" << std::endl;
        stateChanged(PlatformTestState::ConnectingToPlatform);
    }
    else {
        std::cout << "Failed to flash the platform. Exitting..." << std::endl;
        stateChanged(PlatformTestState::TestFinished);
    }
}

void PlatformIdentificationTest::init() {
    mTestState = PlatformTestState::Init;
    mBoardManager.init(false);

    // set up SGJLinkConnector
    // TODO: get this as command line argument.
    mSGJLinkConnector.setExePath("/Applications/SEGGER/JLink/JLinkExe");
    // check if there is a JLinkConnected. need to connect the signals to get the result, this is async process!
//    if(mSGJLinkConnector.checkConnectionRequested()) {
//        std::cout << "JLinkDevice is connected" << std:: endl;
//    }
//    else {
//        std::cout << "No JLinkDevice is connected" << std:: endl;
//    }
}

void PlatformIdentificationTest::identifyPlatform() {
    strata::SerialDevicePtr testDevice = mBoardManager.device(mTestDeviceId);
    if(testDevice != nullptr) {
        std::cout << "class id: " << testDevice->property(strata::DeviceProperties::classId).toStdString() << std::endl;
        std::cout << "device name: " << testDevice->property(strata::DeviceProperties::deviceName).toStdString() << std::endl;
        std::cout << "platform id: " << testDevice->property(strata::DeviceProperties::platformId).toStdString() << std::endl;
        std::cout << "verbose name: " << testDevice->property(strata::DeviceProperties::verboseName).toStdString() << std::endl;
        std::cout << "bootloader version: " << testDevice->property(strata::DeviceProperties::bootloaderVer).toStdString() << std::endl;
        std::cout << "application version: " << testDevice->property(strata::DeviceProperties::applicationVer).toStdString() << std::endl;
    }
    else {
        std::cout << "TestDevicePtr is null :(" << std::endl;
    }
    stateChanged(PlatformTestState::FlashinPlatform);
}

void PlatformIdentificationTest::connectToPlatform() {
    std::cout << "Connecting to platform" << std::endl;
    mBoardManager.reconnect(mTestDeviceId);

    stateChanged(PlatformTestState::Idle); // wait until a board is connected.
}

void PlatformIdentificationTest::flashPlatform() {
    std::cout << "flashing platform" << std::endl;

    // Use SGJLinkConnector to flash a the platform
    mSGJLinkConnector.flashBoardRequested("/Users/zbjmpd/workspace/spyglass/platform/build/applications/template/template-release-explicit-platid.bin", true);
    // change the state. go to idle until we rcive the notification from JLink connector.
    stateChanged(PlatformTestState::Idle);
    // stateChanged(PlatformTestState::ConnectingToPlatform);
}

void PlatformIdentificationTest::onStateChanged(PlatformTestState newState) {
    std::cout << "state changing from " << (int)mTestState << " to " << (int)newState << std::endl;
    mTestState = newState;
    switch (mTestState) {
        case PlatformTestState::Init:
            // handle init state

            // on sucess go to flashing
            break;
        case PlatformTestState::FlashinPlatform:
            // handle Flashing state
            flashPlatform();
            // on success go to connecting
            break;

        case PlatformTestState::IdentifingPlatform:
            // handle identfying
            // on success go to flashing.
            identifyPlatform();
            break;

        case PlatformTestState::ConnectingToPlatform:
            // handle connecting
            connectToPlatform();
            break;

        case PlatformTestState::TestFinished:
            // Done testing
            // print summary?
            // exit :)
            break;
        case PlatformTestState::Idle:
            // wait for the magic to happen!
            break;

        default:
            //unknown state?
        break;
    }
}

void PlatformIdentificationTest::start() {

    // connect BoardManager signals
    // for this test, im interested in the following signals:
    connect(&mBoardManager, &strata::BoardManager::boardReady, this, &PlatformIdentificationTest::newConnection);
    connect(&mBoardManager, &strata::BoardManager::boardDisconnected, this, &PlatformIdentificationTest::closeConnection);

    // get the connected devices and set mTestDeviceId
    auto connectedDevicesList = mBoardManager.readyDeviceIds();
    if(connectedDevicesList.empty()) {
        std::cout << "no connected devices, aborting..." << std::endl;
        stateChanged(PlatformTestState::Idle);
    }
    else {
        mTestDeviceId = connectedDevicesList.front();
    }

    // change the state to flashing
    std::cout << "changing state to flashing..." << std::endl;
    stateChanged(PlatformTestState::FlashinPlatform);
//    switch (mTestState) {
//        case PlatformTestState::Init:
//            // handle init state

//            // on sucess go to flashing
//            break;

//        case PlatformTestState::FlashinPlatform:
//            // handle Flashing state

//            // on success go to connecting
//            break;

//        case PlatformTestState::IdentifingPlatform:
//            // handle identfying

//            // on success go to flashing.
//            break;

//        case PlatformTestState::ConnectingToPlatform:
//            // handle connecting
//            break;

//        case PlatformTestState::TestFinished:
//            // Done testing
//            // print summary?
//            // exit :)
//            break;
//        case PlatformTestState::Idle:
//            // wait for the magic to happen!
//            break;

//        default:
//            //unknown state?
//        break;


//    }
//    while (1) {

//    }
}

void PlatformIdentificationTest::workerThread() {

}
