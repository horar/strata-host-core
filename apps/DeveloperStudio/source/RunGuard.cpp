/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "RunGuard.h"

#include <QCryptographicHash>


namespace
{

QString generateKeyHash(const QString& key, const QString& salt)
{
    QByteArray data;

    data.append(key.toUtf8());
    data.append(salt.toUtf8());
    data = QCryptographicHash::hash(data, QCryptographicHash::Sha1).toHex();

    return data;
}

}


RunGuard::RunGuard(const QString& key)
    : key_(key)
      , sharedMemoryKey_(generateKeyHash(key, QStringLiteral("_strataSharedMemoryKey")))
      , sharedMemory_(sharedMemoryKey_)
      , memoryLockKey_(generateKeyHash(key_, QStringLiteral("_strataMemoryLockKey")))
      , memoryLock_(memoryLockKey_, 1)
{
#ifndef Q_OS_WIN32
    memoryLock_.acquire();
    {
        // not freed when terminates abnormally on *nix; get rid of garbage
        QSharedMemory nix_fix(sharedMemoryKey_);
        if (nix_fix.attach()) {
            nix_fix.detach();
        }
    }
    memoryLock_.release();
#endif
}

RunGuard::~RunGuard()
{
    release();
}

bool RunGuard::isAnotherRunning()
{
    if (sharedMemory_.isAttached()) {
        return false;
    }

    memoryLock_.acquire();
    const bool isRunning = sharedMemory_.attach();
    if (isRunning) {
        sharedMemory_.detach();
    }
    memoryLock_.release();

    return isRunning;
}

bool RunGuard::tryToRun()
{
    if (isAnotherRunning()) {
        return false;
    }

    memoryLock_.acquire();
    const bool segmentCreated = sharedMemory_.create(sizeof(quint64));
    memoryLock_.release();
    if (segmentCreated != true) {
        release();
        return false;
    }

    return true;
}

void RunGuard::release()
{
    memoryLock_.acquire();
    if (sharedMemory_.isAttached()) {
        sharedMemory_.detach();
    }
    memoryLock_.release();
}
