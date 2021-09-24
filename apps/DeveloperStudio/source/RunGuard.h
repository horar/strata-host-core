/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QSharedMemory>
#include <QSystemSemaphore>


class RunGuard final
{
    Q_DISABLE_COPY(RunGuard)

public:
    explicit RunGuard(const QString& key);
    ~RunGuard();

    bool isAnotherRunning();
    bool tryToRun();
    void release();

private:
    const QString key_;

    const QString sharedMemoryKey_;
    QSharedMemory sharedMemory_;

    const QString memoryLockKey_;
    QSystemSemaphore memoryLock_;
};
