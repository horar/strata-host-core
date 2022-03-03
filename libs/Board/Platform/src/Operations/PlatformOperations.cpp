/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <Operations/PlatformOperations.h>
#include <Operations/Backup.h>
#include <Operations/Flash.h>
#include <Operations/Identify.h>
#include <Operations/SetAssistedPlatformId.h>
#include <Operations/SetPlatformId.h>
#include <Operations/StartApplication.h>
#include <Operations/StartBootloader.h>

#include "logging/LoggingQtCategories.h"

namespace strata::platform::operation {

PlatformOperations::PlatformOperations(bool runOperations, bool identifyOverwriteEnabled) :
    runOperations_(runOperations),
    identifyOverwriteEnabled_(identifyOverwriteEnabled)
{ }

PlatformOperations::~PlatformOperations() {
    // will not emit finished in case of queued connection
    stopAllOperations();
}

OperationSharedPtr PlatformOperations::processOperation(const OperationSharedPtr& operation) {
    auto it = operations_.find(operation->deviceId());
    if (it != operations_.end()) {
        OperationSharedPtr oldOperation = it.value();
        if (identifyOverwriteEnabled_ &&
            (operation->type() == Type::Identify) &&
            (oldOperation->type() == Type::Identify)) {
            stopOperation(oldOperation);
        } else {
            return nullptr;
        }
    }

    connect(operation.get(), &operation::BasePlatformOperation::finished,
            this, &PlatformOperations::handleOperationFinished);

    qCDebug(lcPlatformOperation) << "Starting operation" << operation->type()
                                          << "for device Id:" << operation->deviceId();

    // in case of queued finished signal, this insert will overwrite the old operation
    operations_.insert(operation->deviceId(), operation);

    if (runOperations_) {
        operation->run();
    }

    return operation;
}

void PlatformOperations::stopOperation(const QByteArray& deviceId) {
    auto it = operations_.find(deviceId);
    if (it != operations_.end()) {
        qCDebug(lcPlatformOperation) << "Cancelling operation" << it.value()->type()
                                              << "for device Id:" << deviceId;
        stopOperation(it.value());
    }
}

void PlatformOperations::stopOperation(const OperationSharedPtr& operation) {
    // If operation is cancelled, finished is signal will be received (with Result::Cancel)
    // and operation will be removed from operations_ in handleOperationFinished slot.
    operation->cancelOperation();
}

void PlatformOperations::stopAllOperations() {
    // make a copy of operations_ in case of queued signals which would not modify the map immediatelly
    QList<OperationSharedPtr> operations = operations_.values();
    for (auto iter = operations.begin(); iter != operations.end(); ++iter) {
        stopOperation(*iter);
    }
}

OperationSharedPtr PlatformOperations::getOperation(const QByteArray& deviceId) {
    return operations_.value(deviceId);
}

OperationSharedPtr PlatformOperations::Backup(const PlatformPtr& platform) {
    OperationSharedPtr operation(new operation::Backup(platform), operationLaterDeleter);

    return processOperation(operation);
}

OperationSharedPtr PlatformOperations::Flash(const PlatformPtr& platform,
                                             int size,
                                             int chunks,
                                             const QString &md5,
                                             bool flashFirmware) {
    OperationSharedPtr operation (
        new operation::Flash(platform, size, chunks, md5, flashFirmware),
        operationLaterDeleter
    );

    return processOperation(operation);
}

OperationSharedPtr PlatformOperations::Identify(const PlatformPtr& platform,
                                                bool requireFwInfoResponse,
                                                uint maxFwInfoRetries,
                                                std::chrono::milliseconds delay) {
    OperationSharedPtr operation (
        new operation::Identify(platform, requireFwInfoResponse, maxFwInfoRetries, delay),
        operationLaterDeleter
    );

    return processOperation(operation);
}

OperationSharedPtr PlatformOperations::SetAssistedPlatformId(const PlatformPtr& platform) {
    OperationSharedPtr operation(new operation::SetAssistedPlatformId(platform), operationLaterDeleter);

    return processOperation(operation);
}

OperationSharedPtr PlatformOperations::SetPlatformId(const PlatformPtr& platform,
                                                     const command::CmdSetPlatformIdData &data) {
    OperationSharedPtr operation(new operation::SetPlatformId(platform, data), operationLaterDeleter);

    return processOperation(operation);
}

OperationSharedPtr PlatformOperations::StartApplication(const PlatformPtr& platform) {
    OperationSharedPtr operation(new operation::StartApplication(platform), operationLaterDeleter);

    return processOperation(operation);
}

OperationSharedPtr PlatformOperations::StartBootloader(const PlatformPtr& platform) {
    OperationSharedPtr operation(new operation::StartBootloader(platform), operationLaterDeleter);

    return processOperation(operation);
}

void PlatformOperations::operationLaterDeleter(BasePlatformOperation* operation) {
    operation->deleteLater();
}

void PlatformOperations::handleOperationFinished(Result result, int status, QString errorString) {
    operation::BasePlatformOperation *baseOp = qobject_cast<operation::BasePlatformOperation*>(QObject::sender());
    if (baseOp == nullptr) {
        qCCritical(lcPlatformOperation) << "Corrupt operation pointer:" << QObject::sender();
        return;
    }

    const QByteArray deviceId = baseOp->deviceId();
    const Type type = baseOp->type();

    qCDebug(lcPlatformOperation) << "Finished operation" << type
                                          << "for device Id:" << deviceId
                                          << "result:" << result;

    disconnect(baseOp, nullptr, this, nullptr);

    // operation has finished, we do not need BasePlatformOperation object anymore
    // make sure we are erasing correct object from map in case of queued signals
    auto iter = operations_.find(deviceId);
    if ((iter != operations_.end()) && (iter.value().get() == baseOp)) {
        operations_.erase(iter);
    }

    emit finished(deviceId, type, result, status, errorString);
}

}  // namespace
