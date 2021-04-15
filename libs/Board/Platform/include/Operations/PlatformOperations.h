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
     */
    PlatformOperations();

    /*!
     * PlatformOperations destructor.
     */
    virtual ~PlatformOperations();

    /**
     * Start an operation
     * @param deviceId device Id
     * @param operation operation pointer
     */
    void startOperation(const OperationSharedPtr& operation);

    /**
     * Stop an ongoing operation
     * @param deviceId device Id
     */
    void stopOperation(const QByteArray& deviceId);

    /**
     * Stop all ongoing operation
     */
    void stopAllOperations();

    /**
     * Get operation pointer of an ongoing operation
     * @param deviceId device Id
     * @return operation pointer
     */
    OperationSharedPtr getOperation(const QByteArray& deviceId);

    static OperationSharedPtr createOperationBackup(const PlatformPtr& platform);

    static OperationSharedPtr createOperationFlash(const PlatformPtr& platform,
                                                   int size,
                                                   int chunks,
                                                   const QString &md5,
                                                   bool flashFirmware);

    static OperationSharedPtr createOperationIdentify(const PlatformPtr& platform,
                                                      bool requireFwInfoResponse,
                                                      uint maxFwInfoRetries = 1,
                                                      std::chrono::milliseconds delay = std::chrono::milliseconds(0));

    static OperationSharedPtr createOperationSetAssistedPlatformId(const PlatformPtr& platform);

    static OperationSharedPtr createOperationSetPlatformId(const PlatformPtr& platform,
                                                           const command::CmdSetPlatformIdData &data);

    static OperationSharedPtr createOperationStartApplication(const PlatformPtr& platform);

    static OperationSharedPtr createOperationStartBootloader(const PlatformPtr& platform);

    void Backup(const PlatformPtr& platform);

    void Flash(const PlatformPtr& platform, int size, int chunks, const QString &md5, bool flashFirmware);

    void Identify(const PlatformPtr& platform,
                  bool requireFwInfoResponse,
                  uint maxFwInfoRetries = 1,
                  std::chrono::milliseconds delay = std::chrono::milliseconds(0));

    void SetAssistedPlatformId(const PlatformPtr& platform);

    void SetPlatformId(const PlatformPtr& platform,
                       const command::CmdSetPlatformIdData &data);

    void StartApplication(const PlatformPtr& platform);

    void StartBootloader(const PlatformPtr& platform);

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

    QHash<QByteArray, OperationSharedPtr> operations_;
};

}  // namespace
