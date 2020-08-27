#pragma once

#include <QObject>
#include <QPointer>
#include <QProcess>

class DocumentManager;
class CoreInterface;
class HcsNode;
class ResourceLoader;

class SDSModel: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SDSModel)

    Q_PROPERTY(bool hcsConnected READ hcsConnected NOTIFY hcsConnectedChanged)
    Q_PROPERTY(CoreInterface* coreInterface READ coreInterface CONSTANT)
    Q_PROPERTY(DocumentManager* documentManager READ documentManager CONSTANT)
    Q_PROPERTY(ResourceLoader* resourceLoader READ resourceLoader CONSTANT)

public:
    explicit SDSModel(QObject *parent = nullptr);
    virtual ~SDSModel();

    void init(const QString &appDirPath);
    bool startHcs();
    bool killHcs();

    bool hcsConnected() const;
    DocumentManager* documentManager() const;
    CoreInterface* coreInterface() const;
    ResourceLoader* resourceLoader() const;

    /*Temporary solution until strata monitor is done*/
    bool killHcsSilently = false;

public slots:
    void shutdownService();
signals:
    void hcsConnectedChanged();

private slots:
    void startedProcess();
    void finishHcsProcess(int exitCode, QProcess::ExitStatus exitStatus);
    void handleHcsProcessError(QProcess::ProcessError error);

private:
    bool hcsConnected_ = false;
    CoreInterface *coreInterface_;
    DocumentManager *documentManager_;
    ResourceLoader *resourceLoader_;
    HcsNode *remoteHcsNode_;
    QPointer<QProcess> hcsProcess_;
    QString appDirPath_;
    bool externalHcsConnected_{false};

    void setHcsConnected(bool hcsConnected);
};
