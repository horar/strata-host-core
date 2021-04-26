#pragma once

#include <QObject>
#include <QPointer>
#include <QProcess>

class DocumentManager;
class CoreInterface;
class HcsNode;
class ResourceLoader;
class SGNewControlView;
class ProgramControllerManager;

class SDSModel: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SDSModel)

    Q_PROPERTY(bool hcsConnected READ hcsConnected NOTIFY hcsConnectedChanged)
    Q_PROPERTY(CoreInterface* coreInterface READ coreInterface CONSTANT)
    Q_PROPERTY(DocumentManager* documentManager READ documentManager CONSTANT)
    Q_PROPERTY(ResourceLoader* resourceLoader READ resourceLoader CONSTANT)
    Q_PROPERTY(SGNewControlView* newControlView READ newControlView CONSTANT)
    Q_PROPERTY(ProgramControllerManager* programControllerManager READ programControllerManager CONSTANT)

public:
    explicit SDSModel(const QUrl &dealerAddress, QObject *parent = nullptr);
    virtual ~SDSModel();

    bool startHcs();
    bool killHcs();

    bool hcsConnected() const;
    DocumentManager* documentManager() const;
    CoreInterface* coreInterface() const;
    ResourceLoader* resourceLoader() const;
    SGNewControlView* newControlView() const;
    ProgramControllerManager* programControllerManager() const;

    /*Temporary solution until strata monitor is done*/
    bool killHcsSilently = false;

    Q_INVOKABLE QString openLogViewer();

public slots:
    void shutdownService();

signals:
    void hcsConnectedChanged();
    void notifyQmlError(QString notifyQmlError);

private slots:
    void startedProcess();
    void finishHcsProcess(int exitCode, QProcess::ExitStatus exitStatus);
    void handleHcsProcessError(QProcess::ProcessError error);

private:
    bool hcsConnected_ = false;
    CoreInterface *coreInterface_{nullptr};
    DocumentManager *documentManager_{nullptr};
    ResourceLoader *resourceLoader_{nullptr};
    SGNewControlView *newControlView_{nullptr};
    ProgramControllerManager *programControllerManager_{nullptr};
    HcsNode *remoteHcsNode_{nullptr};
    QPointer<QProcess> hcsProcess_;
    bool externalHcsConnected_{false};

    void setHcsConnected(bool hcsConnected);
};
