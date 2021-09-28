/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>
#include <QPointer>
#include <QProcess>

#include "config/UrlConfig.h"

#include <QtLogger.h>

class DocumentManager;
class CoreInterface;
class HcsNode;
class ResourceLoader;
class SGNewControlView;
class FirmwareUpdater;
class PlatformInterfaceGenerator;
class BleDeviceModel;
class VisualEditorUndoStack;

namespace strata::strataRPC
{
class StrataClient;
}

class SDSModel: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SDSModel)

    Q_PROPERTY(bool hcsConnected READ hcsConnected NOTIFY hcsConnectedChanged)
    Q_PROPERTY(CoreInterface* coreInterface READ coreInterface CONSTANT)
    Q_PROPERTY(DocumentManager* documentManager READ documentManager CONSTANT)
    Q_PROPERTY(ResourceLoader* resourceLoader READ resourceLoader CONSTANT)
    Q_PROPERTY(SGNewControlView* newControlView READ newControlView CONSTANT)
    Q_PROPERTY(FirmwareUpdater* firmwareUpdater READ firmwareUpdater CONSTANT)
    Q_PROPERTY(PlatformInterfaceGenerator* platformInterfaceGenerator READ platformInterfaceGenerator CONSTANT)
    Q_PROPERTY(VisualEditorUndoStack* visualEditorUndoStack READ visualEditorUndoStack CONSTANT)
    Q_PROPERTY(strata::sds::config::UrlConfig* urls READ urls CONSTANT)
    Q_PROPERTY(strata::loggers::QtLogger* qtLogger READ qtLogger CONSTANT)
    Q_PROPERTY(BleDeviceModel* bleDeviceModel READ bleDeviceModel CONSTANT)
    Q_PROPERTY(strata::strataRPC::StrataClient* strataClient READ strataClient CONSTANT)

public:
    explicit SDSModel(const QUrl &dealerAddress, const QString &configFilePath, QObject *parent = nullptr);
    virtual ~SDSModel();

    bool startHcs();
    bool killHcs();

    bool hcsConnected() const;
    DocumentManager* documentManager() const;
    CoreInterface* coreInterface() const;
    ResourceLoader* resourceLoader() const;
    SGNewControlView* newControlView() const;
    FirmwareUpdater* firmwareUpdater() const;
    PlatformInterfaceGenerator* platformInterfaceGenerator() const;
    VisualEditorUndoStack* visualEditorUndoStack() const;
    strata::sds::config::UrlConfig* urls() const;
    strata::loggers::QtLogger *qtLogger() const;
    BleDeviceModel *bleDeviceModel() const;
    strata::strataRPC::StrataClient *strataClient() const;
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
    strata::strataRPC::StrataClient *strataClient_{nullptr};
    CoreInterface *coreInterface_{nullptr};
    DocumentManager *documentManager_{nullptr};
    ResourceLoader *resourceLoader_{nullptr};
    SGNewControlView *newControlView_{nullptr};
    FirmwareUpdater *firmwareUpdater_{nullptr};
    PlatformInterfaceGenerator *platformInterfaceGenerator_{nullptr};
    VisualEditorUndoStack *visualEditorUndoStack_{nullptr};
    HcsNode *remoteHcsNode_{nullptr};
    strata::sds::config::UrlConfig *urlConfig_{nullptr};
    QPointer<QProcess> hcsProcess_;
    BleDeviceModel *bleDeviceModel_{nullptr};
    const unsigned hcsIdentifier_;

    void setHcsConnected(bool hcsConnected);
};
