/*
 * Copyright (c) 2018-2022 onsemi.
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
#include <QQmlError>

#include "config/UrlConfig.h"

#include <QtLogger.h>

class DocumentManager;
class CoreInterface;
class HcsNode;
class ResourceLoader;
class FileDownloader;
class SGNewControlView;
class FirmwareUpdater;
class PlatformInterfaceGenerator;
#ifdef APPS_FEATURE_BLE
class BleDeviceModel;
#endif // APPS_FEATURE_BLE
class VisualEditorUndoStack;
class PlatformOperation;

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
    Q_PROPERTY(FileDownloader* fileDownloader READ fileDownloader CONSTANT)
    Q_PROPERTY(SGNewControlView* newControlView READ newControlView CONSTANT)
    Q_PROPERTY(FirmwareUpdater* firmwareUpdater READ firmwareUpdater CONSTANT)
    Q_PROPERTY(PlatformInterfaceGenerator* platformInterfaceGenerator READ platformInterfaceGenerator CONSTANT)
    Q_PROPERTY(VisualEditorUndoStack* visualEditorUndoStack READ visualEditorUndoStack CONSTANT)
    Q_PROPERTY(strata::sds::config::UrlConfig* urls READ urls CONSTANT)
    Q_PROPERTY(strata::loggers::QtLogger* qtLogger READ qtLogger CONSTANT)
#ifdef APPS_FEATURE_BLE
    Q_PROPERTY(BleDeviceModel* bleDeviceModel READ bleDeviceModel CONSTANT)
#endif // APPS_FEATURE_BLE
    Q_PROPERTY(strata::strataRPC::StrataClient* strataClient READ strataClient CONSTANT)
    Q_PROPERTY(PlatformOperation* platformOperation READ platformOperation CONSTANT)
    Q_PROPERTY(bool debugFeaturesEnabled READ debugFeaturesEnabled WRITE setDebugFeaturesEnabled NOTIFY debugFeaturesEnabledChanged)

public:
    explicit SDSModel(const QUrl &dealerAddress, const QString &configFilePath, QObject *parent = nullptr);
    virtual ~SDSModel();

    bool startHcs();
    bool killHcs();

    bool hcsConnected() const;
    DocumentManager* documentManager() const;
    CoreInterface* coreInterface() const;
    ResourceLoader* resourceLoader() const;
    FileDownloader* fileDownloader() const;
    SGNewControlView* newControlView() const;
    FirmwareUpdater* firmwareUpdater() const;
    PlatformInterfaceGenerator* platformInterfaceGenerator() const;
    VisualEditorUndoStack* visualEditorUndoStack() const;
    strata::sds::config::UrlConfig* urls() const;
    strata::loggers::QtLogger *qtLogger() const;
#ifdef APPS_FEATURE_BLE
    BleDeviceModel *bleDeviceModel() const;
#endif // APPS_FEATURE_BLE
    strata::strataRPC::StrataClient *strataClient() const;
    PlatformOperation* platformOperation() const;
    bool debugFeaturesEnabled();
    void setDebugFeaturesEnabled(bool enabled);
    /*Temporary solution until strata monitor is done*/
    bool killHcsSilently = false;

    Q_INVOKABLE QString openLogViewer();

public slots:
    void shutdownService();
    void handleQmlWarning(const QList<QQmlError> &warnings);

signals:
    void hcsConnectedChanged();
    void debugFeaturesEnabledChanged();
    void notifyQmlError(QString notifyQmlError);
    void hcsConnectionEstablished();
    void hcsConnectionLost(int exitStatus, int exitCode);

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
    FileDownloader *fileDownloader_{nullptr};
    SGNewControlView *newControlView_{nullptr};
    FirmwareUpdater *firmwareUpdater_{nullptr};
    PlatformInterfaceGenerator *platformInterfaceGenerator_{nullptr};
    VisualEditorUndoStack *visualEditorUndoStack_{nullptr};
    HcsNode *remoteHcsNode_{nullptr};
    strata::sds::config::UrlConfig *urlConfig_{nullptr};
    PlatformOperation *platformOperation_{nullptr};
    QPointer<QProcess> hcsProcess_;
#ifdef APPS_FEATURE_BLE
    BleDeviceModel *bleDeviceModel_{nullptr};
#endif // APPS_FEATURE_BLE
    const unsigned hcsIdentifier_;
    bool debugFeaturesEnabled_ = false;

    void setHcsConnected(bool hcsConnected);
};
