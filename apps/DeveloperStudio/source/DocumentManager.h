/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef DOCUMENT_MANAGER_H
#define DOCUMENT_MANAGER_H

#include <QObject>
#include <QList>
#include <QString>
#include <QDebug>
#include <QJsonObject>
#include <PlatformInterface/core/CoreInterface.h>
#include "DownloadDocumentListModel.h"
#include "ClassDocuments.h"
#include <DocumentListModel.h>
#include <QMap>

namespace strata::strataRPC
{
class StrataClient;
}

class DocumentManager : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(DocumentManager)

public:
    DocumentManager(strata::strataRPC::StrataClient *strataClient, CoreInterface *coreInterface_,
                    QObject *parent = nullptr);

    virtual ~DocumentManager();

    Q_INVOKABLE ClassDocuments* getClassDocuments(const QString &classId);

    QMap<QString, ClassDocuments*> classes_;

signals:
    void updateProgressRequested(QJsonObject data);
    void populateModelsRequested(QJsonObject data);
    void populateModelsFinished(QString classId);

private slots:
    void documentProgressHandler(QJsonObject data);
    void loadDocumentHandler(QJsonObject data);

    void updateLoadingProgress(QJsonObject data);
    void populateModels(QJsonObject data);
    void platformMetaDataHandler(QJsonObject data);

private:
    strata::strataRPC::StrataClient *strataClient_;
    CoreInterface *coreInterface_;

    void init();
};

#endif // DOCUMENT_MANAGER_H
