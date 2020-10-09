#pragma once

#include "Authenticator.h"
#include "RestClient.h"

#include <BoardManager.h>
#include <FlasherConnector.h>
#include <DownloadManager.h>

#include <QObject>
#include <QPointer>
#include <QNetworkAccessManager>


const QString QSTR_SET_PLATFORM_ID("set_platform_id");

class PrtModel : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(PrtModel)

    Q_PROPERTY(int deviceCount READ deviceCount NOTIFY deviceCountChanged)
    Q_PROPERTY(Authenticator* authenticator READ authenticator CONSTANT)
    Q_PROPERTY(RestClient* restClient READ restClient CONSTANT)
    Q_PROPERTY(QString bootloaderFilepath READ bootloaderFilepath NOTIFY bootloaderFilepathChanged)

public:
    explicit PrtModel(QObject *parent = nullptr);
    virtual ~PrtModel();

    int deviceCount() const;
    Authenticator* authenticator();
    RestClient* restClient();
    QString bootloaderFilepath();

    Q_INVOKABLE QString deviceFirmwareVersion() const;
    Q_INVOKABLE QString deviceFirmwareVerboseName() const;
    Q_INVOKABLE void downloadBinaries(
            QString bootloaderUrl,
            QString bootloaderMd5,
            QString firmwareUrl,
            QString firmwareMd5);

    Q_INVOKABLE void programDevice();
    Q_INVOKABLE void notifyServiceAboutRegistration(
            const QString &classId,
            const QString &platformId);

    Q_INVOKABLE void writeRegistrationData(
            const QString &classId,
            const QString &platfromId,
            int boardCount);

    Q_INVOKABLE void clearBinaries();
    Q_INVOKABLE void requestBootloaderUrl();

signals:
    void boardReady(int deviceId);
    void boardDisconnected(int deviceId);
    void deviceCountChanged();
    void bootloaderFilepathChanged();
    void downloadFirmwareFinished(QString errorString);
    void flasherOperationStateChanged(
            strata::FlasherConnector::Operation operation,
            strata::FlasherConnector::State state,
            QString errorString);

    void flasherProgress(int chunk, int total);
    void flasherFinished(strata::FlasherConnector::Result result);
    void notifyServiceFinished(int boardCount, QString errorString);
    void writeRegistrationDataFinished(QString errorString);
    void bootloaderUrlRequestFinished(QString url, QString md5, QString errorString);

private slots:
    void boardReadyHandler(int deviceId, bool recognized);
    void boardDisconnectedHandler(int deviceId);
    void flasherFinishedHandler(strata::FlasherConnector::Result result);
    void downloadFinishedHandler(QString groupId, QString errorString);
    void messageFromDeviceHandler(QByteArray message);

private:
    strata::BoardManager boardManager_;
    QList<strata::device::DevicePtr> platformList_;
    QPointer<strata::FlasherConnector> flasherConnector_;
    QNetworkAccessManager networkManager_;
    strata::DownloadManager downloadManager_;
    RestClient restClient_;
    Authenticator authenticator_;
    QUrl cloudServiceUrl_;

    QString downloadJobId_;
    QPointer<QTemporaryFile> bootloaderFile_;
    QPointer<QTemporaryFile> firmwareFile_;

    bool fakeDownloadBinaries(
                const QString &bootloaderUrl,
                const QString &firmwareUrl);

    QString resolveConfigFilePath();
    void finishRegistrationCommand(QString errorString);
};
