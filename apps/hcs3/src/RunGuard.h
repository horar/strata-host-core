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
