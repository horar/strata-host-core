#pragma once

#include <QObject>
#include <QPointer>
#include <QProcess>

class DocumentManager;
class CoreInterface;

class SDSModel: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SDSModel)

    Q_PROPERTY(bool hcsConnected READ hcsConnected NOTIFY hcsConnectedChanged)
    Q_PROPERTY(CoreInterface* coreInterface READ coreInterface CONSTANT)
    Q_PROPERTY(DocumentManager* documentManager READ documentManager CONSTANT)

public:
    explicit SDSModel(QObject *parent = nullptr);
    virtual ~SDSModel();

    void init(const QString &appDirPath, const QString &configFilename);
    bool startHcs();
    bool killHcs();

    bool hcsConnected() const;
    DocumentManager* documentManager() const;
    CoreInterface* coreInterface() const;

    /*Temporary solution until strata monitor is done*/
    bool killHcsSilently = false;

signals:
    void hcsConnectedChanged();

private slots:
    void finishHcsProcess(int exitCode, QProcess::ExitStatus exitStatus);
    void handleHcsProcessError(QProcess::ProcessError error);

private:
    bool hcsConnected_ = false;
    CoreInterface *coreInterface_;
    DocumentManager *documentManager_;
    QPointer<QProcess> hcsProcess_;
    QString appDirPath_;
    QString configFilename_;

    void setHcsConnected(bool hcsConnected);
};
