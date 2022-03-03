/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>
#include <PlatformManager.h>
#include <Mock/MockDevice.h>
#include "QtTest.h"

class PlatformManagerTest : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(PlatformManagerTest)

public:
    PlatformManagerTest();

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

    // identify platform test
    void identifyNewPlatformTest();

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
    void onBoardDisconnected(const QByteArray& deviceId);

private:
    /*!
     * \brief Helper function, pretends a new device (serial port) was added.
     * \param deviceId ID of the added device
     * \param deviceName name of the added device
     * \return Created mock device.
     */
    strata::platform::PlatformPtr addMockDevice(const QByteArray& deviceId, const QString& deviceName);
    /*!
     * \brief Helper function, pretends a serial port was removed (only used for clean up after
     * disconnect) \param deviceId ID of the removed device
     */
    void removeMockDevice(const QByteArray& deviceId);

    std::shared_ptr<strata::PlatformManager> platformManager_;
    strata::device::scanner::DeviceScannerPtr mockDeviceScanner_;

    /*!
     * \brief count of calls to onBoardDisconnected slot
     */
    int onBoardDisconnectedCalls_;
    /*!
     * \brief ID of last device calling the onBoardDisconnected slot
     */
    QByteArray lastOnBoardDisconnectedDeviceId_;
};
