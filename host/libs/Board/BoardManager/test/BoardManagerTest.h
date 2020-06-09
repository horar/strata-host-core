#pragma once

#include <QObject>
#include "BoardManagerDerivate.h"
#include "DeviceMock.h"
#include "QtTest.h"

class BoardManagerTest : public QObject
{
    Q_OBJECT

private slots:
    // test init/teardown
    /*!
     * \brief Run before test suite.
     */
    void initTestCase();
    /*!
     * \brief Run after test suite.
     */
    void cleanupTestCase();
    /*!
     * \brief Run before each test.
     */
    void init();
    /*!
     * \brief Run after each test.
     */
    void cleanup();

    // tests
    void connectDisconnectTest();
    void connectMultipleTest();
    void sendMessageTest();

    // signals tests
    void boardConnectedSignalTest();
    void boardDisconnected();
    void boardReady();
    void boardError();
    void readyDeviceIdsChanged();

    // slots tests
    void handleOperationFinished();
    void handleOperationError();
    void handleDeviceError();

protected slots:
    void onBoardDisconnected(int deviceId);

private:
    /*!
     * \brief Helper function, pretends a new device (serial port) was added.
     * \param deviceId ID of the added device
     * \param deviceName name of the added device
     * \return Created mock device.
     */
    std::shared_ptr<DeviceMock> addMockDevice(const int deviceId, const QString deviceName);
    /*!
     * \brief Helper function, pretends a serial port was removed (only used for clean up after
     * disconnect) \param deviceId ID of the removed device
     */
    void removeMockDevice(const int deviceId);

    std::shared_ptr<BoardManagerDerivate> boardManager_;
    /*!
     * \brief count of calls to onBoardDisconnected slot
     */
    int onBoardDisconnectedCalls_;
    /*!
     * \brief ID of last device calling the onBoardDisconnected slot
     */
    int lastOnBoardDisconnectedDeviceId_;
};
