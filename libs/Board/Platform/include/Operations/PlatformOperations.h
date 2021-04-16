#pragma once

#include <memory>
#include <chrono>

#include <QHash>

#include <Operations/BasePlatformOperation.h>
#include <PlatformOperationsData.h>

namespace strata::platform::operation {

typedef std::shared_ptr<BasePlatformOperation> OperationSharedPtr;

class PlatformOperations : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(PlatformOperations)

public:
    /*!
     * BasePlatformOperation constructor.
     * @param runOperations true if operations are to be run automatically, false otherwise
     * @param overwriteEnabled true if operations are to be always created (cancelling old operations), false otherwise
     */
    PlatformOperations(bool runOperations, bool overwriteEnabled);

    /*!
     * PlatformOperations destructor.
     */
    virtual ~PlatformOperations();

    /**
     * Stop ongoing operation with specified device Id
     * @param deviceId device Id
     */
    void stopOperation(const QByteArray& deviceId);

    /**
     * Stop all ongoing operation
     */
    void stopAllOperations();

    /**
     * Get operation pointer of ongoing operation with specified device Id
     * @param deviceId device Id
     * @return operation pointer
     */
    OperationSharedPtr getOperation(const QByteArray& deviceId);

    // -----------------------------------------------------
    // -------functions for creating operations begin-------
    // -----------------------------------------------------

    OperationSharedPtr Backup(const PlatformPtr& platform);

    OperationSharedPtr Flash(const PlatformPtr& platform,
                             int size,
                             int chunks,
                             const QString &md5,
                             bool flashFirmware);

    OperationSharedPtr Identify(const PlatformPtr& platform,
                                bool requireFwInfoResponse,
                                uint maxFwInfoRetries = 1,
                                std::chrono::milliseconds delay = std::chrono::milliseconds(0));

    OperationSharedPtr SetAssistedPlatformId(const PlatformPtr& platform);

    OperationSharedPtr SetPlatformId(const PlatformPtr& platform,
                                     const command::CmdSetPlatformIdData &data);

    OperationSharedPtr StartApplication(const PlatformPtr& platform);

    OperationSharedPtr StartBootloader(const PlatformPtr& platform);

    // ---------------------------------------------------
    // -------functions for creating operations end-------
    // ---------------------------------------------------

signals:
    /*!
     * This signal is emitted when platform operation finishes.
     * @param deviceId device Id
     * @param result value from Result enum
     * @param status specific status for operation
     * @param errorString error string (valid only if operation finishes with error)
     */
    void finished(QByteArray deviceId, Type type, Result result, int status, QString errorString);

private slots:
    void handleOperationFinished(Result result, int status, QString errorString);
private:
    static void operationLaterDeleter(BasePlatformOperation* operation);
    OperationSharedPtr processOperation(const OperationSharedPtr& operation);

    QHash<QByteArray, OperationSharedPtr> operations_;
    bool runOperations_;
    bool overwriteEnabled_;
};

}  // namespace
